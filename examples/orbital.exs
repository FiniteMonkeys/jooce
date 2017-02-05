defmodule Orbital do
  def go do
    state = initialize("Orbital")
    preflight state
    Process.sleep 100
    launch state
  end

  def initialize(name) do
    {:ok, conn} = Jooce.start_link(name)
    {:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
    {:ok, autopilot_pid} = Jooce.Controller.Autopilot.start_link(conn, vessel_id)
    {:ok, control_pid} = Jooce.Controller.Control.start_link(conn, vessel_id)
    {:ok, flight_pid} = Jooce.Controller.Flight.start_link(conn, vessel_id)
    {:ok, resources_pid} = Jooce.Controller.Resources.start(conn, vessel_id)

    %{conn: conn, vessel_id: vessel_id, autopilot_pid: autopilot_pid, control_pid: control_pid, flight_pid: flight_pid, resources_pid: resources_pid}
  end

  def preflight(state) do
    Jooce.Controller.Autopilot.pitch(state.autopilot_pid, 90.0)
    Jooce.Controller.Autopilot.heading(state.autopilot_pid, 90.0)
    Jooce.Controller.Autopilot.on(state.autopilot_pid)
    Jooce.Controller.Control.throttle(state.control_pid, 1.0)
  end

  def launch(state) do
    IO.puts "Launch"
    Jooce.Controller.Control.stage(state.control_pid)
    ascent_phase(state)
  end

  def ascent_phase(state) do
    altitude = Jooce.Controller.Flight.surface_altitude(state.flight_pid)
    cond do
      altitude < 500 ->
        ascent_phase(state)
      true ->
        Jooce.Controller.Autopilot.pitch(state.autopilot_pid, 60.0)
        gravity_turn(state)
    end
  end

  def gravity_turn(state) do
    fuel = Jooce.Controller.Resources.liquid_fuel(state.resources_pid)
    cond do
      fuel <= 0.1 ->
        IO.puts "Launch stage separation"
        Jooce.Controller.Control.throttle(state.control_pid, 0.0)
        Process.sleep 100
        Jooce.Controller.Control.stage(state.control_pid)
        Jooce.Controller.Autopilot.off(state.autopilot_pid)
        Jooce.Controller.Autopilot.sas_on(state.autopilot_pid)
        Process.sleep 100
        Jooce.Controller.Autopilot.sas_mode(state.autopilot_pid, :prograde)
        coast_to_apoapsis(state)
      true ->
        # IO.puts "Fuel: #{fuel}"
        gravity_turn(state)
    end
  end

  # def adjust_gravity_turn(state) do
  #   send state.flight_pid, {:altitude, :mean, self()}
  #   receive do
  #     {:ok, altitude} ->
  #       angle = 90.0 - (:math.pow(altitude / 90_000, 0.4) * 90.0)
  # #       # angle = cond do
  # #       #           angle < 0.01 ->
  # #       #             0.01
  # #       #           angle > 89.9 ->
  # #       #             89.9
  # #       #           true ->
  # #       #             angle
  # #       #         end
  #       IO.puts "#{altitude}: #{angle}"
  # #       send state.autopilot_pid, {:pitch, angle}
  # #       Process.sleep 1000
  #       gravity_turn(state)
  #   end
  # end

  def coast_to_apoapsis(state, altitude \\ 0) do
    new_altitude = Jooce.Controller.Flight.mean_altitude(state.flight_pid)
    cond do
      new_altitude <= 80_000 ->
        coast_to_apoapsis(state, new_altitude)
      new_altitude < altitude ->
        Jooce.Controller.Autopilot.sas_on(state.autopilot_pid)
        Process.sleep 100
        Jooce.Controller.Autopilot.sas_mode(state.autopilot_pid, :retrograde)
        descent_phase(state)
      true ->
        Jooce.Controller.Autopilot.sas_off(state.autopilot_pid)
        coast_to_apoapsis(state, new_altitude)
    end
  end

  def descent_phase(state) do
    altitude = Jooce.Controller.Flight.mean_altitude(state.flight_pid)
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
    altitude = Jooce.Controller.Flight.surface_altitude(state.flight_pid)
    cond do
      altitude > 0.1 ->
        landing_phase(state)
      true ->
        IO.puts("Landed")
        # Jooce.stop(state.conn)
    end
  end
end

Orbital.go
