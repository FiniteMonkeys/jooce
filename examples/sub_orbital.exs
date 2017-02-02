defmodule SubOrbital do

  ##
  ## controllers
  ##

  defmodule Flight do
    def start(state) do
      Task.start(fn -> loop(state) end)
    end

    defp loop(state) do
      receive do
        {:altitude, :mean, from} ->
          {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
          GenEvent.notify(state.event_mgr, {:altitude, {:mean, altitude}})
          send from, {:ok, altitude}
        {:altitude, :surface, from} ->
          {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
          GenEvent.notify(state.event_mgr, {:altitude, {:surface, altitude}})
          send from, {:ok, altitude}
      after
        100 ->
          {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
          GenEvent.notify(state.event_mgr, {:altitude, {:mean, altitude}})
      end
      loop(state)
    end
  end

  defmodule Resources do
    def start(state) do
      Task.start(fn -> loop(state) end)
    end

    defp loop(state) do
      receive do
        {:resources, :liquid_fuel, from} ->
          {:ok, fuel, _} = Jooce.SpaceCenter.resources_amount(state.conn, state.resources_id, "LiquidFuel")
          GenEvent.notify(state.event_mgr, {:resources, {:liquid_fuel, fuel}})
          send from, {:ok, fuel}
      after
        100 ->
          {:ok, fuel, _} = Jooce.SpaceCenter.resources_amount(state.conn, state.resources_id, "LiquidFuel")
          GenEvent.notify(state.event_mgr, {:resources, {:liquid_fuel, fuel}})
      end
      loop(state)
    end
  end

  ##
  ## event handlers
  ##

  defmodule AltitudeHandler do
    use GenEvent

    def handle_event({:altitude, {:mean, altitude}}, state) do
      IO.puts("Mean altitude: #{altitude}")
      {:ok, state}
    end

    def handle_event({:altitude, {:surface, altitude}}, state) do
      IO.puts("Surface altitude: #{altitude}")
      {:ok, state}
    end

    def handle_event({_, _}, state) do
      {:ok, state}
    end
  end

  ##
  ## main body of script
  ##

  def go do
    state = initialize()
    preflight state
    Process.sleep 100
    launch state
  end

  def initialize do
    state = %{}

    {:ok, event_mgr} = GenEvent.start_link
    state = Map.put(state, :event_mgr, event_mgr)

    {:ok, conn} = Jooce.start_link("Sub Orbital")
    state = Map.put(state, :conn, conn)

    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    state = Map.put(state, :vessel_id, vessel_id)

    {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
    state = Map.put(state, :autopilot_id, autopilot_id)

    {:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)
    state = Map.put(state, :control_id, control_id)

    {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
    state = Map.put(state, :flight_id, flight_id)

    {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)
    state = Map.put(state, :resources_id, resources_id)

    {:ok, flight_pid} = Flight.start(state)
    state = Map.put(state, :flight_pid, flight_pid)

    {:ok, resources_pid} = Resources.start(state)
    state = Map.put(state, :resources_pid, resources_pid)

    # GenEvent.add_handler(event_mgr, AltitudeHandler, [])

    state
  end

  def preflight(state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(state.conn, state.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(state.conn, state.autopilot_id)
    {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, 1.0)
  end

  def launch(state) do
    IO.puts "Launch"
    {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
    ascent_phase(state)
  end

  def ascent_phase(state, altitude \\ 0) do
    send state.flight_pid, {:altitude, :mean, self()}
    receive do
      {:ok, new_altitude} when new_altitude < 500 ->
        ascent_phase(state, new_altitude)
      {:ok, _} ->
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, 60.0)
        gravity_turn(state)
    after
      100 ->
        ascent_phase(state, altitude)
    end
  end

  def gravity_turn(state) do
    send state.resources_pid, {:resources, :liquid_fuel, self()}
    receive do
      {:ok, fuel} when fuel <= 0.1 ->
        IO.puts "Launch stage separation"
        {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, 0.0)
        Process.sleep 100
        {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(state.conn, state.autopilot_id)
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
        Process.sleep 100
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 2)   # prograde
        coast_to_apoapsis(state)
      {:ok, _} ->
        gravity_turn(state)
    after
      100 ->
        gravity_turn(state)
    end
  end

  def coast_to_apoapsis(state, altitude \\ 0) do
    send state.flight_pid, {:altitude, :mean, self()}
    receive do
      {:ok, new_altitude} when new_altitude <= 80_000 ->
        coast_to_apoapsis(state, new_altitude)
      {:ok, new_altitude} when new_altitude < altitude ->
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
        Process.sleep 100
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 3)   # retrograde
        descent_phase(state, new_altitude)
      {:ok, new_altitude} ->
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
        coast_to_apoapsis(state, new_altitude)
    after
      100 ->
        coast_to_apoapsis(state, altitude)
    end
  end

  def descent_phase(state, altitude) do
    send state.flight_pid, {:altitude, :mean, self()}
    receive do
      {:ok, new_altitude} when new_altitude > 60_000 ->
        descent_phase(state, new_altitude)
      {:ok, new_altitude} when new_altitude > 6_000 ->
        {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
        descent_phase(state, new_altitude)
      {:ok, new_altitude} ->
        IO.puts "Deploying parachute"
        {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
        landing_phase(state, new_altitude)
    after
      100 ->
        descent_phase(state, altitude)
    end
  end

  def landing_phase(state, altitude) when altitude > 0.1 do
    send state.flight_pid, {:altitude, :surface, self()}
    receive do
      {:ok, new_altitude} when new_altitude > 0.1 ->
        landing_phase(state, new_altitude)
      {:ok, _} ->
        IO.puts("Landed")
        Jooce.stop(state.conn)
    after
      100 ->
        landing_phase(state, altitude)
    end
  end
end

SubOrbital.go
