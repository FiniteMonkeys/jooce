defmodule Simple do

  def go do
    state = initialize() |> preflight
    Process.sleep 100
    launch state
  end

  def initialize do
    state = %{conn: nil, vessel_id: nil, autopilot_id: nil, control_id: nil, flight_id: nil, resources_id: nil}

    {:ok, conn} = Jooce.start_link("Sub Orbital Flight")
    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
    {:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)
    {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
    {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)

    %{state | conn: conn, vessel_id: vessel_id, autopilot_id: autopilot_id, control_id: control_id, flight_id: flight_id, resources_id: resources_id}
  end

  def preflight(state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(state.conn, state.autopilot_id, 90.0)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(state.conn, state.autopilot_id)
    {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, 1.0)

    state
  end

  def launch(state) do
    IO.puts "Launch"
    {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
    IO.puts "Ascent phase"
    ascent_phase(state, 0)
  end

  def ascent_phase(state, altitude) when altitude < 500 do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
    Process.sleep 100
    ascent_phase(state, new_altitude)
  end

  def ascent_phase(state, _altitude) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, 60.0)
    gravity_turn(state, 1)
  end

  def gravity_turn(state, fuel) when fuel > 0.1 do
    {:ok, new_fuel, _} = Jooce.SpaceCenter.resources_amount(state.conn, state.resources_id, "LiquidFuel")
    Process.sleep 100
    gravity_turn(state, new_fuel)
  end

  def gravity_turn(state, _fuel) do
    IO.puts "Launch stage separation"
    {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, 0.0)
    Process.sleep 100
    {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(state.conn, state.autopilot_id)
    IO.puts "Coast to apoapsis"
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
    Process.sleep 100
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 2)   # prograde
    coast_to_apoapsis(state, 0)
  end

  def coast_to_apoapsis(state, altitude) when altitude < 80000 do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
    Process.sleep 100
    coast_to_apoapsis(state, new_altitude)
  end

  def coast_to_apoapsis(state, altitude) do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
    if new_altitude < altitude do
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
      Process.sleep 100
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 3)   # retrograde
      IO.puts "Descent phase"
      descent_phase(state, new_altitude)
    else
      {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
      Process.sleep 100
      coast_to_apoapsis(state, new_altitude)
    end
  end

  def descent_phase(state, altitude) when altitude > 60000 do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
    Process.sleep 100
    descent_phase(state, new_altitude)
  end

  def descent_phase(state, _altitude) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
    Process.sleep 100
    IO.puts "Reentry"
    reentry(state, new_altitude)
  end

  def reentry(state, altitude) when altitude > 6000 do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
    Process.sleep 100
    reentry(state, new_altitude)
  end

  def reentry(state, altitude) do
    {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
    Process.sleep 100
    landing_phase(state, altitude)
  end

  def landing_phase(state, altitude) when altitude > 0.1 do
    {:ok, new_altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
    Process.sleep 100
    landing_phase(state, new_altitude)
  end

  def landing_phase(state, _altitude) do
    IO.puts("Landed")
    Jooce.stop(state.conn)
    Kernel.exit(self())
  end
end

Simple.go
