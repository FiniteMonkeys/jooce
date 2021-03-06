# -*- coding: utf-8 -*-
"""kRPC script to put a command pod into orbit.

Based on the sample code at https://krpc.github.io/krpc/tutorials/launch-into-orbit.html
with modifications for our own rocket, as well as a few tweaks.

"""
import math
import time
import krpc

##
## constants
##
turn_start_altitude = 0
turn_end_altitude = 90000
target_altitude = 90000
max_q = 20000
orbits = 3

##
## variables for max Q PID
##
k_p = 2.0
k_d = 1.0
throttle_pid_d_accum = 0

##
## connect to KSP
##
conn = krpc.connect(name = 'orbital.py')
vessel = conn.space_center.active_vessel

##
## set up streams for telemetry
##
ut = conn.add_stream(getattr, conn.space_center, 'ut')
altitude = conn.add_stream(getattr, vessel.flight(), 'mean_altitude')
q = conn.add_stream(getattr, vessel.flight(), 'dynamic_pressure')
apoapsis = conn.add_stream(getattr, vessel.orbit, 'apoapsis_altitude')
stage_1_resources = vessel.resources_in_decouple_stage(stage = 4, cumulative = False)
stage_1_fuel = conn.add_stream(stage_1_resources.amount, 'LiquidFuel')
stage_2_resources = vessel.resources_in_decouple_stage(stage = 2, cumulative = False)
stage_2_fuel = conn.add_stream(stage_2_resources.amount, 'LiquidFuel')
latitude = conn.add_stream(getattr, vessel.flight(), 'latitude')
longitude = conn.add_stream(getattr, vessel.flight(), 'longitude')

##
## pre-launch setup
##
vessel.control.sas = False
vessel.control.rcs = False
vessel.control.throttle = 1.0

ksc_longitude = longitude()
deorbit_longitude = ksc_longitude - 49.0

##
## launch
##
print('Launch')
vessel.control.activate_next_stage()
vessel.auto_pilot.engage()
vessel.auto_pilot.target_pitch_and_heading(90, 90)

##
## ascent phase
##
stage_1_separated = False
turn_angle = 0
while True:

    # Gravity turn
    if altitude() > turn_start_altitude and altitude() < turn_end_altitude:
        frac = ((altitude() - turn_start_altitude) / (turn_end_altitude - turn_start_altitude)) ** 0.4
        new_turn_angle = frac * 90
        if abs(new_turn_angle - turn_angle) > 0.5:
            turn_angle = new_turn_angle
            vessel.auto_pilot.target_pitch_and_heading(90 - turn_angle, 90)

    # Separate first stage when finished
    if not stage_1_separated:
        if stage_1_fuel() < 0.1:
            print('MECO')
            vessel.control.throttle = 0.0
            time.sleep(1)
            print('First stage separation')
            vessel.control.activate_next_stage()
            stage_1_separated = True
            time.sleep(1)
            vessel.control.activate_next_stage()
            vessel.control.throttle = 1.0

    # Decrease throttle when approaching target apoapsis
    if apoapsis() > target_altitude * 0.9:
        break

    # throttle back if Q is too large
    q_error = max_q - q()
    p_value = k_p * q_error
    d_value = k_d * (q_error - throttle_pid_d_accum)
    throttle_pid_d_accum = q_error
    new_throttle_value = 1.0 + ((p_value + d_value) / 40000)
    if new_throttle_value > 1.0:
        new_throttle_value = 1.0
    elif new_throttle_value < 0.0:
        new_throttle_value = 0.0
    vessel.control.throttle = new_throttle_value

##
## disable engines when target apoapsis is reached
##
vessel.control.throttle = 0.25
while apoapsis() < target_altitude:
    if not stage_1_separated:
        if stage_1_fuel() < 0.1:
            print('MECO')
            vessel.control.throttle = 0.0
            time.sleep(1)
            print('First stage separation')
            vessel.control.activate_next_stage()
            stage_1_separated = True
            time.sleep(1)
            vessel.control.activate_next_stage()
            vessel.control.throttle = 0.25
    pass
vessel.control.throttle = 0.0
time.sleep(1)

##
## dump the first stage if we still have it
##
if not stage_1_separated:
    print('MECO')
    vessel.control.throttle = 0.0
    time.sleep(1)
    print('First stage separation')
    vessel.control.activate_next_stage()
    stage_1_separated = True
    time.sleep(1)
    vessel.control.activate_next_stage()
    vessel.control.throttle = 0.0

##
## wait until out of atmosphere
##
print('Coasting out of atmosphere')
while altitude() < 70500:
    pass

print('Circularizing')

##
## plan circularization burn (using vis-viva equation)
##
mu = vessel.orbit.body.gravitational_parameter
r = vessel.orbit.apoapsis
a1 = vessel.orbit.semi_major_axis
a2 = r
v1 = math.sqrt(mu * ((2.0 / r) - (1.0 / a1)))
v2 = math.sqrt(mu * ((2.0 / r) - (1.0 / a2)))
delta_v = v2 - v1
node = vessel.control.add_node(ut() + vessel.orbit.time_to_apoapsis, prograde = delta_v)

##
## calculate burn time (using rocket equation)
##
F = vessel.available_thrust
Isp = vessel.specific_impulse * 9.82
m0 = vessel.mass
m1 = m0 / math.exp(delta_v / Isp)
flow_rate = F / Isp
burn_time = (m0 - m1) / flow_rate

##
## orient ship
##
vessel.auto_pilot.disengage()
vessel.control.sas = True
time.sleep(1)
vessel.control.sas_mode = conn.space_center.SASMode.maneuver
vessel.auto_pilot.wait()

##
## wait until burn
##
burn_ut = ut() + vessel.orbit.time_to_apoapsis - (burn_time / 2.0)
lead_time = 5
conn.space_center.warp_to(burn_ut - lead_time)

##
## execute burn
##
time_to_apoapsis = conn.add_stream(getattr, vessel.orbit, 'time_to_apoapsis')
while time_to_apoapsis() - (burn_time / 2.0) > 0:
    pass
vessel.control.throttle = 1.0
time.sleep(burn_time - 0.1)
vessel.control.throttle = 0.05
remaining_burn = conn.add_stream(node.remaining_burn_vector, node.reference_frame)
while remaining_burn()[1] > 0:
    pass
vessel.control.throttle = 0.0
node.remove()

##
## orbiting
##
print('In orbit')

vessel.auto_pilot.disengage()
vessel.control.sas = True
time.sleep(1)
vessel.control.sas_mode = conn.space_center.SASMode.prograde
vessel.auto_pilot.wait()

current_orbit = 1
print('Starting orbit %d' % current_orbit)
previous_longitude = ksc_longitude
current_longitude = longitude()

while True:
    if (previous_longitude < ksc_longitude) and (current_longitude >= ksc_longitude):
        current_orbit = current_orbit + 1
        print('Starting orbit %d' % current_orbit)
    if (current_orbit > orbits) and (previous_longitude < deorbit_longitude) and (current_longitude >= deorbit_longitude):
        break
    time.sleep(1)
    previous_longitude = current_longitude
    current_longitude = longitude()

##
## deorbiting
##
print('Deorbiting')

vessel.auto_pilot.disengage()
vessel.control.sas = True
time.sleep(1)
vessel.control.sas_mode = conn.space_center.SASMode.retrograde
vessel.auto_pilot.wait()
time.sleep(1)

vessel.control.throttle = 1.0
while stage_2_fuel() > 0.1:
    pass
print('SECO')
vessel.control.throttle = 0.0
time.sleep(1)
vessel.control.activate_next_stage()

while altitude() > 60000:
    time.sleep(1)

vessel.control.sas = False

while altitude() > 6000:
    pass

print('Deploying parachute')
vessel.control.activate_next_stage()

print('Final longitude: %.4f' % longitude())
