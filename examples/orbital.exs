defmodule Orbital do
  defmodule StageOnMECO do
    use GenEvent

    def init(state) do
      {:ok, Map.put(state, :enabled, true)}
    end

    def handle_event({:amount, :liquid_fuel, amount}, %{enabled: enabled} = state) when (amount <= 0.1) and enabled do
      IO.puts "MECO"
      Jooce.Controller.Control.throttle(state.control_pid, 0.0)

      IO.puts "Launch stage separation"
      Jooce.Controller.Control.stage(state.control_pid)

      Jooce.Controller.Autopilot.off(state.autopilot_pid)
      Jooce.Controller.Autopilot.sas_on(state.autopilot_pid)
      Jooce.Controller.Autopilot.sas_mode(state.autopilot_pid, :prograde)

      # Jooce.Monitor.Resources.remove_handler(state.resources_pid, Orbital.StageOnMECO, state)
      {:ok, %{state | enabled: false}}
    end

    def handle_event(_, state) do
      {:ok, state}
    end
  end

  defmodule GravityTurn do
    use GenEvent

    def init(state) do
      state = Map.put(state, :enabled, true)
      state = Map.put(state, :pitch, 90.0)
      {:ok, state}
    end

    def handle_event({:altitude, :mean, altitude}, %{enabled: enabled, pitch: old_pitch} = state) when (altitude > 500) and (altitude < 90_000) and enabled do
      pitch = 90.0 - (:math.pow(altitude / 90_000, 0.4) * 90.0)
      pitch = cond do
                pitch < 0.01 ->
                  0.01
                pitch > 89.9 ->
                  89.9
                true ->
                  pitch
              end
      if abs(old_pitch - pitch) > 0.5 do
        # IO.puts "#{altitude}: #{pitch}"
        {:ok, %{state | pitch: pitch}}
      else
        {:ok, state}
      end
    end

    def handle_event({:altitude, :mean, altitude}, %{enabled: enabled} = state) when (altitude > 90_000) and enabled do
      # Jooce.Monitor.Flight.remove_handler(state.flight_pid, Orbital.GravityTurn, state)
      {:ok, %{state | enabled: false}}
    end

    def handle_event(_, state) do
      {:ok, state}
    end
  end

  ##
  ## main script body
  ##

  def go do
    state = initialize("Orbital")
    preflight state
    launch state
  end

  def initialize(name) do
    {:ok, conn} = Jooce.start_link(name)
    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    {:ok, autopilot_pid} = Jooce.Controller.Autopilot.start_link(conn, vessel_id)
    {:ok, control_pid} = Jooce.Controller.Control.start_link(conn, vessel_id)
    {:ok, flight_pid} = Jooce.Monitor.Flight.start_link(conn, vessel_id)
    {:ok, resources_pid} = Jooce.Monitor.Resources.start(conn, vessel_id)

    state = %{conn: conn, vessel_id: vessel_id, autopilot_pid: autopilot_pid, control_pid: control_pid, flight_pid: flight_pid, resources_pid: resources_pid}
    Jooce.Monitor.Flight.add_handler(flight_pid, Orbital.GravityTurn, state)
    Jooce.Monitor.Resources.add_handler(resources_pid, Orbital.StageOnMECO, state)

    state
  end

  def preflight(state) do
    Jooce.Controller.Autopilot.pitch(state.autopilot_pid, 90.0)
    Jooce.Controller.Autopilot.heading(state.autopilot_pid, 90.0)
    Jooce.Controller.Autopilot.roll(state.autopilot_pid, 0.0)
    Jooce.Controller.Autopilot.on(state.autopilot_pid)
    Jooce.Controller.Control.throttle(state.control_pid, 1.0)
  end

  def launch(state) do
    IO.puts "Launch"
    Jooce.Controller.Control.stage(state.control_pid)
    ascent_phase(state)
  end

  def ascent_phase(state) do
    altitude = Jooce.Monitor.Flight.surface_altitude(state.flight_pid)
    cond do
      altitude < 500 ->
        ascent_phase(state)
      true ->
        Jooce.Controller.Autopilot.pitch(state.autopilot_pid, 60.0)
        gravity_turn(state)
    end
  end

  def gravity_turn(state) do
    fuel = Jooce.Monitor.Resources.liquid_fuel(state.resources_pid)
    cond do
      fuel <= 0.1 ->
        coast_to_apoapsis(state)
      true ->
        gravity_turn(state)
    end
  end

  def coast_to_apoapsis(state, altitude \\ 0) do
    new_altitude = Jooce.Monitor.Flight.mean_altitude(state.flight_pid)
    cond do
      new_altitude <= 80_000 ->
        coast_to_apoapsis(state, new_altitude)
      new_altitude < altitude ->
        Jooce.Controller.Autopilot.sas_on(state.autopilot_pid)
        Process.sleep 100
        Jooce.Controller.Autopilot.sas_mode(state.autopilot_pid, :retrograde)
        Jooce.Controller.Autopilot.roll(state.autopilot_pid, 0.0)
        Jooce.Controller.Autopilot.on(state.autopilot_pid)
        Process.sleep 100
        descent_phase(state)
      true ->
        Jooce.Controller.Autopilot.sas_off(state.autopilot_pid)
        coast_to_apoapsis(state, new_altitude)
    end
  end

  def descent_phase(state) do
    altitude = Jooce.Monitor.Flight.mean_altitude(state.flight_pid)
    cond do
      altitude > 60_000 ->
        descent_phase(state)
      altitude > 5_000 ->
        Jooce.Controller.Autopilot.sas_off(state.autopilot_pid)
        descent_phase(state)
      true ->
        IO.puts "Deploying parachute"
        Jooce.Controller.Control.stage(state.control_pid)
        landing_phase(state)
    end
  end

  def landing_phase(state) do
    altitude = Jooce.Monitor.Flight.surface_altitude(state.flight_pid)
    cond do
      altitude > 0.1 ->
        landing_phase(state)
      true ->
        IO.puts("Landed")
    end
  end
end

Orbital.go
