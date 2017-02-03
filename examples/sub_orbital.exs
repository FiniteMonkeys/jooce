defmodule SubOrbital do

  ##
  ## controllers
  ##

  defmodule Autopilot do
    def start(conn, vessel_id) do
      {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
      Task.start(fn -> loop(%{conn: conn, autopilot_id: autopilot_id}) end)
    end

    defp loop(state) do
      receive do
        {:heading, value} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(state.conn, state.autopilot_id, value)
        {:off} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(state.conn, state.autopilot_id)
        {:on} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(state.conn, state.autopilot_id)
        {:pitch, value} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, value)
        {:sas, :off} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
        {:sas, :on} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
        {:sas, :prograde} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 2)
        {:sas, :retrograde} ->
          {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 3)
      end
      loop(state)
    end
  end

  defmodule Control do
    def start(conn, vessel_id) do
      {:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)
      Task.start(fn -> loop(%{conn: conn, control_id: control_id}) end)
    end

    defp loop(state) do
      receive do
        {:throttle, value} ->
          {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, value)
        {:stage} ->
          {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
      end
      loop(state)
    end
  end

  defmodule Flight do
    def start(conn, vessel_id) do
      {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
      Task.start(fn -> loop(%{conn: conn, flight_id: flight_id}) end)
    end

    defp loop(state) do
      receive do
        {:altitude, :mean, from} ->
          {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
          send from, {:ok, altitude}
        {:altitude, :surface, from} ->
          {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
          send from, {:ok, altitude}
      end
      loop(state)
    end
  end

  defmodule Resources do
    def start(conn, vessel_id) do
      {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)
      Task.start(fn -> loop(%{conn: conn, resources_id: resources_id}) end)
    end

    defp loop(state) do
      receive do
        {:resources, :liquid_fuel, from} ->
          {:ok, fuel, _} = Jooce.SpaceCenter.resources_amount(state.conn, state.resources_id, "LiquidFuel")
          send from, {:ok, fuel}
      end
      loop(state)
    end
  end

  ##
  ## main body of script
  ##

  def go do
    state = initialize("Sub Orbital")
    preflight state
    Process.sleep 100
    launch state
  end

  def initialize(name) do
    {:ok, conn} = Jooce.start_link(name)
    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    {:ok, autopilot_pid} = Autopilot.start(conn, vessel_id)
    {:ok, control_pid} = Control.start(conn, vessel_id)
    {:ok, flight_pid} = Flight.start(conn, vessel_id)
    {:ok, resources_pid} = Resources.start(conn, vessel_id)

    %{conn: conn, vessel_id: vessel_id, autopilot_pid: autopilot_pid, control_pid: control_pid, flight_pid: flight_pid, resources_pid: resources_pid}
  end

  def preflight(state) do
    send state.autopilot_pid, {:pitch, 90.0}
    send state.autopilot_pid, {:heading, 90.0}
    send state.autopilot_pid, {:on}
    send state.control_pid, {:throttle, 1.0}
  end

  def launch(state) do
    IO.puts "Launch"
    send state.control_pid, {:stage}
    ascent_phase(state)
  end

  def ascent_phase(state, altitude \\ 0) do
    send state.flight_pid, {:altitude, :mean, self()}
    receive do
      {:ok, new_altitude} when new_altitude < 500 ->
        ascent_phase(state, new_altitude)
      {:ok, _} ->
        send state.autopilot_pid, {:pitch, 60.0}
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
        send state.control_pid, {:throttle, 0.0}
        Process.sleep 100
        send state.control_pid, {:stage}
        send state.autopilot_pid, {:off}
        send state.autopilot_pid, {:sas, :on}
        Process.sleep 100
        send state.autopilot_pid, {:sas, :prograde}
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
        send state.autopilot_pid, {:sas, :on}
        Process.sleep 100
        send state.autopilot_pid, {:sas, :retrograde}
        descent_phase(state, new_altitude)
      {:ok, new_altitude} ->
        send state.autopilot_pid, {:sas, :off}
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
      {:ok, new_altitude} when new_altitude > 5_000 ->
        send state.autopilot_pid, {:sas, :off}
        descent_phase(state, new_altitude)
      {:ok, new_altitude} ->
        IO.puts "Deploying parachute"
        send state.control_pid, {:stage}
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
