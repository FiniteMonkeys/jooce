{:ok, conn} = Jooce.start_link("Sub Orbital Flight")

{:ok, vessel_id, _} = Jooce.SpaceCenter.active_vessel(conn)
{:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
{:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)

{:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(conn, autopilot_id, 90.0)
{:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(conn, autopilot_id, 90.0)

{:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(conn, autopilot_id)
{:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(conn, control_id, 1.0)
Process.sleep(1000)

IO.puts("Launch!")
{:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(conn, control_id)

# while vessel.resources.amount('SolidFuel') > 0.1:
#     time.sleep(1)
# print('Booster separation')
# vessel.control.activate_next_stage()
#
# while vessel.flight().mean_altitude < 10000:
#     time.sleep(1)
#
# print('Gravity turn')
# vessel.auto_pilot.target_pitch_and_heading(60, 90)
#
# while vessel.orbit.apoapsis_altitude < 100000:
#     time.sleep(1)
# print('Launch stage separation')
# vessel.control.throttle = 0
# time.sleep(1)
# vessel.control.activate_next_stage()
# vessel.auto_pilot.disengage()
#
# while vessel.flight().surface_altitude > 1000:
#     time.sleep(1)
# vessel.control.activate_next_stage()
#
# while vessel.flight(vessel.orbit.body.reference_frame).vertical_speed < -0.1:
#     print('Altitude = %.1f meters' % vessel.flight().surface_altitude)
#     time.sleep(1)
# print('Landed!')

Jooce.stop(conn)
