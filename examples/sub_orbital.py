import time
import krpc
conn = krpc.connect(name='sub_orbital.py')

vessel = conn.space_center.active_vessel

vessel.auto_pilot.target_pitch_and_heading(90, 90)
vessel.auto_pilot.engage()
vessel.control.throttle = 1
time.sleep(1)

print('Launch!')
vessel.control.activate_next_stage()

while vessel.flight().mean_altitude < 500:
    time.sleep(1)

print('Gravity turn')
vessel.auto_pilot.target_pitch_and_heading(60, 90)

while vessel.resources.amount('LiquidFuel') > 0.1:
    time.sleep(1)

print('Launch stage separation')
vessel.control.throttle = 0
time.sleep(1)
vessel.control.activate_next_stage()
vessel.auto_pilot.disengage()

while vessel.flight().surface_altitude > 5000:
    time.sleep(1)
vessel.control.activate_next_stage()

while vessel.flight(vessel.orbit.body.reference_frame).vertical_speed < -0.1:
    print('Altitude = %.1f meters' % vessel.flight().surface_altitude)
    time.sleep(1)
print('Landed!')
