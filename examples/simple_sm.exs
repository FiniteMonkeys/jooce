defmodule Simple do

  defmodule FlightSM do
    use GenStateMachine, callback_mode: :handle_event_function

    # client API

    def start_link(jooce) do
      IO.puts "In FlightSM.start_link"
      GenStateMachine.start_link(__MODULE__, jooce)
    end

    def stop(pid) do
      IO.puts "In FlightSM.stop"
      GenStateMachine.stop(pid)
    end

    # jooce change functions -- events?

    def launch(pid) do
      IO.puts "In FlightSM.launch"
      GenStateMachine.call(pid, :launch)
    end

    # callbacks

    def init(jooce), do: {:ok, :idle, jooce}
    def terminate(_reason, _state, _data), do: :void
    def code_change(_vsn, state, jooce, _extra), do: {:ok, state, jooce}

    ## launch
    def handle_event({:call, from}, :launch, :idle, jooce) do
      {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(jooce.conn, jooce.control_id)
      {:next_state, :ascent, {jooce, 0}, [{:reply, from, :ascent}]}
    end
    def handle_event({:call, from}, :launch, _state, jooce), do: {:keep_state, jooce, [{:reply, from, jooce}]}

    ## ascent
    def handle_event(:enter, _old, :ascent, {jooce, altitude}) when altitude < 500 do
      IO.puts "In FlightSM.handle_event(:enter, _old, :ascent) with altitude < 500"
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(jooce.conn, jooce.flight_id)
      Process.sleep 100
      {:repeat_state, {jooce, new_altitude}}
    end
    def handle_event(:enter, _old, :ascent, {jooce, _altitude}) do
      IO.puts "In FlightSM.handle_event(:enter, _old, :ascent)"
      {:next_state, :gravity_turn, {jooce, 1}}
    end

    ## gravity turn
    def handle_event(:enter, _old, :gravity_turn, {jooce, fuel}) when fuel > 0.1 do
      {:ok, new_fuel, _} = Jooce.SpaceCenter.resources_amount(jooce.conn, jooce.resources_id, "LiquidFuel")
      Process.sleep 100
      {:repeat_state, {jooce, new_fuel}}
    end
    def handle_event(:enter, _old, :gravity_turn, {jooce, _fuel}) do
      {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(jooce.conn, jooce.control_id, 0.0)
      Process.sleep 100
      {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(jooce.conn, jooce.control_id)
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(jooce.conn, jooce.autopilot_id)
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(jooce.conn, jooce.autopilot_id, true)
      Process.sleep 100
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(jooce.conn, jooce.autopilot_id, 2)   # prograde
      {:next_state, :coast_to_apoapsis, {jooce, 0, 1}}
    end

    ## coast to apoapsis
    def handle_event(:enter, _old, :coast_to_apoapsis, {jooce, previous_altitude, altitude}) when altitude < previous_altitude do
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(jooce.conn, jooce.autopilot_id, true)
      Process.sleep 100
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(jooce.conn, jooce.autopilot_id, 3)   # retrograde
      {:next_state, :descent, {jooce, altitude}}
    end
    def handle_event(:enter, _old, :coast_to_apoapsis, {jooce, _previous_altitude, altitude}) when altitude < 80_000 do
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(jooce.conn, jooce.flight_id)
      Process.sleep 100
      {:repeat_state, {jooce, altitude, new_altitude}}
    end
    def handle_event(:enter, _old, :coast_to_apoapsis, {jooce, _previous_altitude, altitude}) do
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(jooce.conn, jooce.flight_id)
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(jooce.conn, jooce.autopilot_id, false)
      Process.sleep 100
      {:repeat_state, {jooce, altitude, new_altitude}}
      # :stop
    end

    ## descent
    def handle_event(:enter, _old, :descent, {jooce, altitude}) when altitude > 60_000 do
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(jooce.conn, jooce.flight_id)
      Process.sleep 100
      {:repeat_state, {jooce, new_altitude}}
    end
    def handle_event(:enter, _old, :descent, {jooce, altitude}) do
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(jooce.conn, jooce.autopilot_id, false)
      {:next_state, :reentry, {jooce, altitude}}
    end

    ## reentry
    def handle_event(:enter, _old, :reentry, {jooce, altitude}) when altitude > 6_000 do
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(jooce.conn, jooce.flight_id)
      Process.sleep 100
      {:repeat_state, {jooce, new_altitude}}
    end
    def handle_event(:enter, _old, :reentry, {jooce, altitude}) do
      {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(jooce.conn, jooce.control_id)
      Process.sleep 100
      {:next_state, :landing, {jooce, altitude}}
    end

    ## landing
    def handle_event(:enter, _old, :landing, {jooce, altitude}) when altitude > 0.1 do
      {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(jooce.conn, jooce.flight_id)
      Process.sleep 100
      {:repeat_state, {jooce, new_altitude}}
    end
    def handle_event(:enter, _old, :landing, {jooce, _altitude}) do
      Jooce.stop(jooce.conn)
      # Kernel.exit(self())
      :stop
    end
  end

  def initialize do
    jooce = %{conn: nil, vessel_id: nil, autopilot_id: nil, control_id: nil, flight_id: nil, resources_id: nil}

    {:ok, conn} = Jooce.start_link("Sub Orbital Flight")
    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
    {:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)
    {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
    {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)

    %{jooce | conn: conn, vessel_id: vessel_id, autopilot_id: autopilot_id, control_id: control_id, flight_id: flight_id, resources_id: resources_id}
  end

  def preflight(jooce) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(jooce.conn, jooce.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(jooce.conn, jooce.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(jooce.conn, jooce.autopilot_id)
    {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(jooce.conn, jooce.control_id, 1.0)

    jooce
  end

  def loop do
    receive do
      {:EXIT, _pid, :normal} ->
        :normal
      {:EXIT, pid, reason} ->
        IO.puts "#{inspect self()} received {:EXIT, #{inspect pid}, #{reason}}"
        reason
      msg ->
        IO.puts "#{inspect self()} received #{inspect msg}"
        loop()
    end
  end

  def go do
    jooce = initialize() |> preflight
    Process.flag(:trap_exit, true)
    {:ok, pid} = FlightSM.start_link(jooce)
    Process.sleep 100
    FlightSM.launch(pid)
    loop()
  end
end

Simple.go
