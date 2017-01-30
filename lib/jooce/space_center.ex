defmodule Jooce.SpaceCenter do

# Enumerations:
#   CameraMode
#     0 = Automatic
#     1 = Free
#     2 = Chase
#     3 = Locked
#     4 = Orbital
#     5 = IVA
#     6 = Map
#   CargoBayState
#     0 = Open
#     1 = Closed
#     2 = Opening
#     3 = Closing
#   DockingPortState
#     0 = Ready
#     1 = Docked
#     2 = Docking
#     3 = Undocking
#     4 = Shielded
#     5 = Moving
#   LandingGearState
#     0 = Deployed
#     1 = Retracted
#     2 = Deploying
#     3 = Retracting
#     4 = Broken
#   LandingLegState
#     0 = Deployed
#     1 = Retracted
#     2 = Deploying
#     3 = Retracting
#     4 = Broken
#   ParachuteState
#     0 = Active
#     1 = Cut
#     2 = Deployed
#     3 = SemiDeployed
#     4 = Stowed
#   RadiatorState
#     0 = Extended
#     1 = Retracted
#     2 = Extending
#     3 = Retracting
#     4 = Broken
#   ResourceConverterState
#     0 = Running
#     1 = Idle
#     2 = MissingResource
#     3 = StorageFull
#     4 = Capacity
#     5 = Unknown
#   ResourceHarvesterState
#     0 = Deploying
#     1 = Deployed
#     2 = Retracting
#     3 = Retracted
#     4 = Active
#   SolarPanelState
#     0 = Extended
#     1 = Retracted
#     2 = Extending
#     3 = Retracting
#     4 = Broken
#   ResourceFlowMode
#     0 = Vessel
#     1 = Stage
#     2 = Adjacent
#     3 = None
#   SASMode
#     0 = StabilityAssist
#     1 = Maneuver
#     2 = Prograde
#     3 = Retrograde
#     4 = Normal
#     5 = AntiNormal
#     6 = Radial
#     7 = AntiRadial
#     8 = Target
#     9 = AntiTarget
#   SpeedMode
#     0 = Orbit
#     1 = Surface
#     2 = Target
#   VesselSituation
#     0 = PreLaunch
#     1 = Orbiting
#     2 = SubOrbital
#     3 = Escaping
#     4 = Flying
#     5 = Landed
#     6 = Splashed
#     7 = Docked
#   VesselType
#     0 = Ship
#     1 = Station
#     2 = Lander
#     3 = Probe
#     4 = Rover
#     5 = Base
#     6 = Debris
#   WarpMode
#     0 = Rails
#     1 = Physics
#     2 = None
# Procedures:

@doc ~S"""
Returns the ID of the active vessel.

## RPC signature
get_ActiveVessel() : uint64
"""
@spec active_vessel(pid) :: {atom, integer, integer}
def active_vessel(conn) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "get_ActiveVessel") do
    {:ok, return_value, time} ->
      {vessel_id, _} = :gpb.decode_varint(return_value)
      {:ok, vessel_id, time}
    {:error, _reason, _time} = error ->
      error
  end
end

@doc ~S"""
Sets the ID of the active vessel.

## RPC signature
set_ActiveVessel(uint64 value)
"""
def set_active_vessel(conn, vessel_id) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "set_ActiveVessel", [{vessel_id, :uint64, nil}])
end

#   get_Vessels() : KRPC.List
#   get_Bodies() : KRPC.Dictionary
#   get_TargetBody() : uint64
#   set_TargetBody(uint64 value)
#   get_TargetVessel() : uint64
#   set_TargetVessel(uint64 value)
#   get_TargetDockingPort() : uint64
#   set_TargetDockingPort(uint64 value)
#   ClearTarget()

@doc ~S"""
Returns a list of vessels from the given `craftDirectory` that can be launched.

## RPC signature
LaunchableVessels(string craftDirectory) : KRPC.List
"""
def launchable_vessels(conn, craft_directory \\ "VAB") do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "LaunchableVessels", [{craft_directory, :string, nil}]) do
    {:ok, return_value, time} ->
      list = for name <- Jooce.Protobuf.List.decode(return_value).items, into: [], do: :gpb.decode_type(:string, name, nil)
      {:ok, list, time}
    {:error, _reason, _time} = error ->
      error
  end
end

#   LaunchVessel(string craftDirectory, string name, string launchSite)
#   LaunchVesselFromVAB(string name)
#   LaunchVesselFromSPH(string name)
#   Save(string name)
#   Load(string name)
#   Quicksave()
#   Quickload()
#   CanRailsWarpAt(int32 factor) : bool
#   WarpTo(double ut, float maxRailsRate, float maxPhysicsRate)
#   TransformPosition(KRPC.Tuple position, uint64 from, uint64 to) : KRPC.Tuple
#   TransformDirection(KRPC.Tuple direction, uint64 from, uint64 to) : KRPC.Tuple
#   TransformRotation(KRPC.Tuple rotation, uint64 from, uint64 to) : KRPC.Tuple
#   TransformVelocity(KRPC.Tuple position, KRPC.Tuple velocity, uint64 from, uint64 to) : KRPC.Tuple

#   get_WaypointManager() : uint64
#   get_Camera() : uint64
#   get_UT() : double
#   get_G() : double
#   get_WarpMode() : int32
#   get_WarpRate() : float
#   get_WarpFactor() : float
#   get_RailsWarpFactor() : int32
#   set_RailsWarpFactor(int32 value)
#   get_PhysicsWarpFactor() : int32
#   set_PhysicsWarpFactor(int32 value)
#   get_MaximumRailsWarpFactor() : int32
#   get_FARAvailable() : bool

@doc ~S"""
Engage the auto-pilot.

## RPC signature
AutoPilot_Engage(uint64 this)
"""
def autopilot_engage(conn, autopilot_id) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_Engage", [{autopilot_id, :uint64, nil}])
end

@doc ~S"""
Disengage the auto-pilot.

## RPC signature
AutoPilot_Disengage(uint64 this)
"""
def autopilot_disengage(conn, autopilot_id) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_Disengage", [{autopilot_id, :uint64, nil}])
end

#   AutoPilot_Wait(uint64 this)
#   AutoPilot_TargetPitchAndHeading(uint64 this, float pitch, float heading)
#   AutoPilot_get_Error(uint64 this) : float
#   AutoPilot_get_PitchError(uint64 this) : float
#   AutoPilot_get_HeadingError(uint64 this) : float
#   AutoPilot_get_RollError(uint64 this) : float
#   AutoPilot_get_ReferenceFrame(uint64 this) : uint64
#   AutoPilot_set_ReferenceFrame(uint64 this, uint64 value)

@doc ~S"""
Gets the target pitch angle, in degrees, between -90° and +90°.

## RPC signature
AutoPilot_get_TargetPitch(uint64 this) : float
"""
def autopilot_get_target_pitch(conn, autopilot_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_get_TargetPitch", [{autopilot_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      {target_pitch, _} = :gpb.decode_type(:float, return_value, nil)
      {:ok, target_pitch, time}
    {:error, _reason, _time} = error ->
      error
  end
end

@doc ~S"""
Sets the target pitch angle, in degrees, between -90° and +90°.

## RPC signature
AutoPilot_set_TargetPitch(uint64 this, float value)
"""
def autopilot_set_target_pitch(conn, autopilot_id, value) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_set_TargetPitch", [{autopilot_id, :uint64, nil}, {value, :float, nil}])
end

@doc ~S"""
Gets the target heading angle, in degrees, between 0° and 360°.

## RPC signature
AutoPilot_get_TargetHeading(uint64 this) : float
"""
def autopilot_get_target_heading(conn, autopilot_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_get_TargetHeading", [{autopilot_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      {target_heading, _} = :gpb.decode_type(:float, return_value, nil)
      {:ok, target_heading, time}
    {:error, _reason, _time} = error ->
      error
  end
end

@doc ~S"""
Sets the target heading angle, in degrees, between 0° and 360°.

## RPC signature
AutoPilot_set_TargetHeading(uint64 this, float value)
"""
def autopilot_set_target_heading(conn, autopilot_id, value) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "AutoPilot_set_TargetHeading", [{autopilot_id, :uint64, nil}, {value, :float, nil}])
end

#   AutoPilot_get_TargetRoll(uint64 this) : float
#   AutoPilot_set_TargetRoll(uint64 this, float value)
#   AutoPilot_get_TargetDirection(uint64 this) : KRPC.Tuple
#   AutoPilot_set_TargetDirection(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_SAS(uint64 this) : bool
#   AutoPilot_set_SAS(uint64 this, bool value)
#   AutoPilot_get_SASMode(uint64 this) : int32
#   AutoPilot_set_SASMode(uint64 this, int32 value)
#   AutoPilot_get_RollThreshold(uint64 this) : double
#   AutoPilot_set_RollThreshold(uint64 this, double value)
#   AutoPilot_get_StoppingTime(uint64 this) : KRPC.Tuple
#   AutoPilot_set_StoppingTime(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_DecelerationTime(uint64 this) : KRPC.Tuple
#   AutoPilot_set_DecelerationTime(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_AttenuationAngle(uint64 this) : KRPC.Tuple
#   AutoPilot_set_AttenuationAngle(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_AutoTune(uint64 this) : bool
#   AutoPilot_set_AutoTune(uint64 this, bool value)
#   AutoPilot_get_TimeToPeak(uint64 this) : KRPC.Tuple
#   AutoPilot_set_TimeToPeak(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_Overshoot(uint64 this) : KRPC.Tuple
#   AutoPilot_set_Overshoot(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_PitchPIDGains(uint64 this) : KRPC.Tuple
#   AutoPilot_set_PitchPIDGains(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_RollPIDGains(uint64 this) : KRPC.Tuple
#   AutoPilot_set_RollPIDGains(uint64 this, KRPC.Tuple value)
#   AutoPilot_get_YawPIDGains(uint64 this) : KRPC.Tuple
#   AutoPilot_set_YawPIDGains(uint64 this, KRPC.Tuple value)
#   Camera_get_Mode(uint64 this) : int32
#   Camera_set_Mode(uint64 this, int32 value)
#   Camera_get_Pitch(uint64 this) : float
#   Camera_set_Pitch(uint64 this, float value)
#   Camera_get_Heading(uint64 this) : float
#   Camera_set_Heading(uint64 this, float value)
#   Camera_get_Distance(uint64 this) : float
#   Camera_set_Distance(uint64 this, float value)
#   Camera_get_MinPitch(uint64 this) : float
#   Camera_get_MaxPitch(uint64 this) : float
#   Camera_get_MinDistance(uint64 this) : float
#   Camera_get_MaxDistance(uint64 this) : float
#   Camera_get_DefaultDistance(uint64 this) : float
#   Camera_get_FocussedBody(uint64 this) : uint64
#   Camera_set_FocussedBody(uint64 this, uint64 value)
#   Camera_get_FocussedVessel(uint64 this) : uint64
#   Camera_set_FocussedVessel(uint64 this, uint64 value)
#   Camera_get_FocussedNode(uint64 this) : uint64
#   Camera_set_FocussedNode(uint64 this, uint64 value)
#   CelestialBody_SurfaceHeight(uint64 this, double latitude, double longitude) : double
#   CelestialBody_BedrockHeight(uint64 this, double latitude, double longitude) : double
#   CelestialBody_MSLPosition(uint64 this, double latitude, double longitude, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_SurfacePosition(uint64 this, double latitude, double longitude, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_BedrockPosition(uint64 this, double latitude, double longitude, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_BiomeAt(uint64 this, double latitude, double longitude) : string
#   CelestialBody_Position(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_Velocity(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_Rotation(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_Direction(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_AngularVelocity(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   CelestialBody_get_Name(uint64 this) : string
#   CelestialBody_get_Satellites(uint64 this) : KRPC.List
#   CelestialBody_get_Mass(uint64 this) : float
#   CelestialBody_get_GravitationalParameter(uint64 this) : float
#   CelestialBody_get_SurfaceGravity(uint64 this) : float
#   CelestialBody_get_RotationalPeriod(uint64 this) : float
#   CelestialBody_get_RotationalSpeed(uint64 this) : float
#   CelestialBody_get_EquatorialRadius(uint64 this) : float
#   CelestialBody_get_SphereOfInfluence(uint64 this) : float
#   CelestialBody_get_Orbit(uint64 this) : uint64
#   CelestialBody_get_HasAtmosphere(uint64 this) : bool
#   CelestialBody_get_AtmosphereDepth(uint64 this) : float
#   CelestialBody_get_HasAtmosphericOxygen(uint64 this) : bool
#   CelestialBody_get_Biomes(uint64 this) : KRPC.Set
#   CelestialBody_get_FlyingHighAltitudeThreshold(uint64 this) : float
#   CelestialBody_get_SpaceHighAltitudeThreshold(uint64 this) : float
#   CelestialBody_get_ReferenceFrame(uint64 this) : uint64
#   CelestialBody_get_NonRotatingReferenceFrame(uint64 this) : uint64
#   CelestialBody_get_OrbitalReferenceFrame(uint64 this) : uint64

@doc ~S"""
Activates the next stage. Equivalent to pressing the space bar in-game.

## RPC signature
Control_ActivateNextStage(uint64 this) : KRPC.List
"""
def control_activate_next_stage(conn, control_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "Control_ActivateNextStage", [{control_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      list = for id <- Jooce.Protobuf.List.decode(return_value).items, into: [], do: :gpb.decode_type(:uint64, id, nil)
      {:ok, list, time}
    {:error, _reason, _time} = error ->
      error
  end
end

#   Control_GetActionGroup(uint64 this, uint32 group) : bool
#   Control_SetActionGroup(uint64 this, uint32 group, bool state)
#   Control_ToggleActionGroup(uint64 this, uint32 group)
#   Control_AddNode(uint64 this, double ut, float prograde, float normal, float radial) : uint64
#   Control_RemoveNodes(uint64 this)
#   Control_get_SAS(uint64 this) : bool
#   Control_set_SAS(uint64 this, bool value)
#   Control_get_SASMode(uint64 this) : int32
#   Control_set_SASMode(uint64 this, int32 value)
#   Control_get_SpeedMode(uint64 this) : int32
#   Control_set_SpeedMode(uint64 this, int32 value)
#   Control_get_RCS(uint64 this) : bool
#   Control_set_RCS(uint64 this, bool value)
#   Control_get_Gear(uint64 this) : bool
#   Control_set_Gear(uint64 this, bool value)
#   Control_get_Lights(uint64 this) : bool
#   Control_set_Lights(uint64 this, bool value)
#   Control_get_Brakes(uint64 this) : bool
#   Control_set_Brakes(uint64 this, bool value)
#   Control_get_Abort(uint64 this) : bool
#   Control_set_Abort(uint64 this, bool value)

@doc ~S"""
Gets the state of the throttle. A value between 0 and 1.

## RPC signature
Control_get_Throttle(uint64 this) : float
"""
def control_get_throttle(conn, control_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "Control_get_Throttle", [{control_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      {value, _} = :gpb.decode_type(:float, return_value, nil)
      {:ok, value, time}
    {:error, _reason, _time} = error ->
      error
  end
end

@doc ~S"""
Sets the state of the throttle. A value between 0 and 1.

## RPC signature
Control_set_Throttle(uint64 this, float value)
"""
def control_set_throttle(conn, control_id, value) do
  Jooce.Connection.call_rpc(conn, "SpaceCenter", "Control_set_Throttle", [{control_id, :uint64, nil}, {value, :float, nil}])
end

#   Control_get_Pitch(uint64 this) : float
#   Control_set_Pitch(uint64 this, float value)
#   Control_get_Yaw(uint64 this) : float
#   Control_set_Yaw(uint64 this, float value)
#   Control_get_Roll(uint64 this) : float
#   Control_set_Roll(uint64 this, float value)
#   Control_get_Forward(uint64 this) : float
#   Control_set_Forward(uint64 this, float value)
#   Control_get_Up(uint64 this) : float
#   Control_set_Up(uint64 this, float value)
#   Control_get_Right(uint64 this) : float
#   Control_set_Right(uint64 this, float value)
#   Control_get_WheelThrottle(uint64 this) : float
#   Control_set_WheelThrottle(uint64 this, float value)
#   Control_get_WheelSteering(uint64 this) : float
#   Control_set_WheelSteering(uint64 this, float value)
#   Control_get_CurrentStage(uint64 this) : int32
#   Control_get_Nodes(uint64 this) : KRPC.List
#   Flight_get_GForce(uint64 this) : float
#   Flight_get_MeanAltitude(uint64 this) : double
#   Flight_get_SurfaceAltitude(uint64 this) : double
#   Flight_get_BedrockAltitude(uint64 this) : double
#   Flight_get_Elevation(uint64 this) : double
#   Flight_get_Latitude(uint64 this) : double
#   Flight_get_Longitude(uint64 this) : double
#   Flight_get_Velocity(uint64 this) : KRPC.Tuple
#   Flight_get_Speed(uint64 this) : double
#   Flight_get_HorizontalSpeed(uint64 this) : double
#   Flight_get_VerticalSpeed(uint64 this) : double
#   Flight_get_CenterOfMass(uint64 this) : KRPC.Tuple
#   Flight_get_Rotation(uint64 this) : KRPC.Tuple
#   Flight_get_Direction(uint64 this) : KRPC.Tuple
#   Flight_get_Pitch(uint64 this) : float
#   Flight_get_Heading(uint64 this) : float
#   Flight_get_Roll(uint64 this) : float
#   Flight_get_Prograde(uint64 this) : KRPC.Tuple
#   Flight_get_Retrograde(uint64 this) : KRPC.Tuple
#   Flight_get_Normal(uint64 this) : KRPC.Tuple
#   Flight_get_AntiNormal(uint64 this) : KRPC.Tuple
#   Flight_get_Radial(uint64 this) : KRPC.Tuple
#   Flight_get_AntiRadial(uint64 this) : KRPC.Tuple
#   Flight_get_AtmosphereDensity(uint64 this) : float
#   Flight_get_DynamicPressure(uint64 this) : float
#   Flight_get_StaticPressureAtMSL(uint64 this) : float
#   Flight_get_StaticPressure(uint64 this) : float
#   Flight_get_AerodynamicForce(uint64 this) : KRPC.Tuple
#   Flight_get_Lift(uint64 this) : KRPC.Tuple
#   Flight_get_Drag(uint64 this) : KRPC.Tuple
#   Flight_get_SpeedOfSound(uint64 this) : float
#   Flight_get_Mach(uint64 this) : float
#   Flight_get_ReynoldsNumber(uint64 this) : float
#   Flight_get_TrueAirSpeed(uint64 this) : float
#   Flight_get_EquivalentAirSpeed(uint64 this) : float
#   Flight_get_TerminalVelocity(uint64 this) : float
#   Flight_get_AngleOfAttack(uint64 this) : float
#   Flight_get_SideslipAngle(uint64 this) : float
#   Flight_get_TotalAirTemperature(uint64 this) : float
#   Flight_get_StaticAirTemperature(uint64 this) : float
#   Flight_get_StallFraction(uint64 this) : float
#   Flight_get_DragCoefficient(uint64 this) : float
#   Flight_get_LiftCoefficient(uint64 this) : float
#   Flight_get_BallisticCoefficient(uint64 this) : float
#   Flight_get_ThrustSpecificFuelConsumption(uint64 this) : float
#   Node_BurnVector(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Node_RemainingBurnVector(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Node_Remove(uint64 this)
#   Node_Position(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Node_Direction(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Node_get_Prograde(uint64 this) : float
#   Node_set_Prograde(uint64 this, float value)
#   Node_get_Normal(uint64 this) : float
#   Node_set_Normal(uint64 this, float value)
#   Node_get_Radial(uint64 this) : float
#   Node_set_Radial(uint64 this, float value)
#   Node_get_DeltaV(uint64 this) : float
#   Node_set_DeltaV(uint64 this, float value)
#   Node_get_RemainingDeltaV(uint64 this) : float
#   Node_get_UT(uint64 this) : double
#   Node_set_UT(uint64 this, double value)
#   Node_get_TimeTo(uint64 this) : double
#   Node_get_Orbit(uint64 this) : uint64
#   Node_get_ReferenceFrame(uint64 this) : uint64
#   Node_get_OrbitalReferenceFrame(uint64 this) : uint64
#   Orbit_ReferencePlaneNormal(uint64 referenceFrame) : KRPC.Tuple
#   Orbit_ReferencePlaneDirection(uint64 referenceFrame) : KRPC.Tuple
#   Orbit_RadiusAtTrueAnomaly(uint64 this, double trueAnomaly) : double
#   Orbit_TrueAnomalyAtRadius(uint64 this, double radius) : double
#   Orbit_TrueAnomalyAtUT(uint64 this, double ut) : double
#   Orbit_UTAtTrueAnomaly(uint64 this, double trueAnomaly) : double
#   Orbit_EccentricAnomalyAtUT(uint64 this, double ut) : double
#   Orbit_OrbitalSpeedAt(uint64 this, double time) : double
#   Orbit_get_Body(uint64 this) : uint64
#   Orbit_get_Apoapsis(uint64 this) : double
#   Orbit_get_Periapsis(uint64 this) : double
#   Orbit_get_ApoapsisAltitude(uint64 this) : double
#   Orbit_get_PeriapsisAltitude(uint64 this) : double
#   Orbit_get_SemiMajorAxis(uint64 this) : double
#   Orbit_get_SemiMinorAxis(uint64 this) : double
#   Orbit_get_Radius(uint64 this) : double
#   Orbit_get_Speed(uint64 this) : double
#   Orbit_get_Period(uint64 this) : double
#   Orbit_get_TimeToApoapsis(uint64 this) : double
#   Orbit_get_TimeToPeriapsis(uint64 this) : double
#   Orbit_get_Eccentricity(uint64 this) : double
#   Orbit_get_Inclination(uint64 this) : double
#   Orbit_get_LongitudeOfAscendingNode(uint64 this) : double
#   Orbit_get_ArgumentOfPeriapsis(uint64 this) : double
#   Orbit_get_MeanAnomalyAtEpoch(uint64 this) : double
#   Orbit_get_Epoch(uint64 this) : double
#   Orbit_get_MeanAnomaly(uint64 this) : double
#   Orbit_get_EccentricAnomaly(uint64 this) : double
#   Orbit_get_TrueAnomaly(uint64 this) : double
#   Orbit_get_NextOrbit(uint64 this) : uint64
#   Orbit_get_TimeToSOIChange(uint64 this) : double
#   Orbit_get_OrbitalSpeed(uint64 this) : double
#   CargoBay_get_Part(uint64 this) : uint64
#   CargoBay_get_State(uint64 this) : int32
#   CargoBay_get_Open(uint64 this) : bool
#   CargoBay_set_Open(uint64 this, bool value)
#   ControlSurface_get_Part(uint64 this) : uint64
#   ControlSurface_get_PitchEnabled(uint64 this) : bool
#   ControlSurface_set_PitchEnabled(uint64 this, bool value)
#   ControlSurface_get_YawEnabled(uint64 this) : bool
#   ControlSurface_set_YawEnabled(uint64 this, bool value)
#   ControlSurface_get_RollEnabled(uint64 this) : bool
#   ControlSurface_set_RollEnabled(uint64 this, bool value)
#   ControlSurface_get_Inverted(uint64 this) : bool
#   ControlSurface_set_Inverted(uint64 this, bool value)
#   ControlSurface_get_Deployed(uint64 this) : bool
#   ControlSurface_set_Deployed(uint64 this, bool value)
#   ControlSurface_get_SurfaceArea(uint64 this) : float
#   ControlSurface_get_AvailableTorque(uint64 this) : KRPC.Tuple
#   Decoupler_Decouple(uint64 this) : uint64
#   Decoupler_get_Part(uint64 this) : uint64
#   Decoupler_get_Decoupled(uint64 this) : bool
#   Decoupler_get_Staged(uint64 this) : bool
#   Decoupler_get_Impulse(uint64 this) : float
#   DockingPort_Undock(uint64 this) : uint64
#   DockingPort_Position(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   DockingPort_Direction(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   DockingPort_Rotation(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   DockingPort_get_Part(uint64 this) : uint64
#   DockingPort_get_State(uint64 this) : int32
#   DockingPort_get_DockedPart(uint64 this) : uint64
#   DockingPort_get_ReengageDistance(uint64 this) : float
#   DockingPort_get_HasShield(uint64 this) : bool
#   DockingPort_get_Shielded(uint64 this) : bool
#   DockingPort_set_Shielded(uint64 this, bool value)
#   DockingPort_get_ReferenceFrame(uint64 this) : uint64
#   Engine_ToggleMode(uint64 this)
#   Engine_get_Part(uint64 this) : uint64
#   Engine_get_Active(uint64 this) : bool
#   Engine_set_Active(uint64 this, bool value)
#   Engine_get_Thrust(uint64 this) : float
#   Engine_get_AvailableThrust(uint64 this) : float
#   Engine_get_MaxThrust(uint64 this) : float
#   Engine_get_MaxVacuumThrust(uint64 this) : float
#   Engine_get_ThrustLimit(uint64 this) : float
#   Engine_set_ThrustLimit(uint64 this, float value)
#   Engine_get_Thrusters(uint64 this) : KRPC.List
#   Engine_get_SpecificImpulse(uint64 this) : float
#   Engine_get_VacuumSpecificImpulse(uint64 this) : float
#   Engine_get_KerbinSeaLevelSpecificImpulse(uint64 this) : float
#   Engine_get_PropellantNames(uint64 this) : KRPC.List
#   Engine_get_Propellants(uint64 this) : KRPC.List
#   Engine_get_PropellantRatios(uint64 this) : KRPC.Dictionary
#   Engine_get_HasFuel(uint64 this) : bool
#   Engine_get_Throttle(uint64 this) : float
#   Engine_get_ThrottleLocked(uint64 this) : bool
#   Engine_get_CanRestart(uint64 this) : bool
#   Engine_get_CanShutdown(uint64 this) : bool
#   Engine_get_HasModes(uint64 this) : bool
#   Engine_get_Mode(uint64 this) : string
#   Engine_set_Mode(uint64 this, string value)
#   Engine_get_Modes(uint64 this) : KRPC.Dictionary
#   Engine_get_AutoModeSwitch(uint64 this) : bool
#   Engine_set_AutoModeSwitch(uint64 this, bool value)
#   Engine_get_Gimballed(uint64 this) : bool
#   Engine_get_GimbalRange(uint64 this) : float
#   Engine_get_GimbalLocked(uint64 this) : bool
#   Engine_set_GimbalLocked(uint64 this, bool value)
#   Engine_get_GimbalLimit(uint64 this) : float
#   Engine_set_GimbalLimit(uint64 this, float value)
#   Engine_get_AvailableTorque(uint64 this) : KRPC.Tuple
#   Experiment_Run(uint64 this)
#   Experiment_Transmit(uint64 this)
#   Experiment_Dump(uint64 this)
#   Experiment_Reset(uint64 this)
#   Experiment_get_Part(uint64 this) : uint64
#   Experiment_get_Inoperable(uint64 this) : bool
#   Experiment_get_Deployed(uint64 this) : bool
#   Experiment_get_Rerunnable(uint64 this) : bool
#   Experiment_get_HasData(uint64 this) : bool
#   Experiment_get_Data(uint64 this) : KRPC.List
#   Experiment_get_Available(uint64 this) : bool
#   Experiment_get_Biome(uint64 this) : string
#   Experiment_get_ScienceSubject(uint64 this) : uint64
#   Fairing_Jettison(uint64 this)
#   Fairing_get_Part(uint64 this) : uint64
#   Fairing_get_Jettisoned(uint64 this) : bool
#   Force_Remove(uint64 this)
#   Force_get_Part(uint64 this) : uint64
#   Force_get_ForceVector(uint64 this) : KRPC.Tuple
#   Force_set_ForceVector(uint64 this, KRPC.Tuple value)
#   Force_get_Position(uint64 this) : KRPC.Tuple
#   Force_set_Position(uint64 this, KRPC.Tuple value)
#   Force_get_ReferenceFrame(uint64 this) : uint64
#   Force_set_ReferenceFrame(uint64 this, uint64 value)
#   Intake_get_Part(uint64 this) : uint64
#   Intake_get_Open(uint64 this) : bool
#   Intake_set_Open(uint64 this, bool value)
#   Intake_get_Speed(uint64 this) : float
#   Intake_get_Flow(uint64 this) : float
#   Intake_get_Area(uint64 this) : float
#   LandingGear_get_Part(uint64 this) : uint64
#   LandingGear_get_Deployable(uint64 this) : bool
#   LandingGear_get_State(uint64 this) : int32
#   LandingGear_get_Deployed(uint64 this) : bool
#   LandingGear_set_Deployed(uint64 this, bool value)
#   LandingGear_get_IsGrounded(uint64 this) : bool
#   LandingLeg_get_Part(uint64 this) : uint64
#   LandingLeg_get_State(uint64 this) : int32
#   LandingLeg_get_Deployed(uint64 this) : bool
#   LandingLeg_set_Deployed(uint64 this, bool value)
#   LandingLeg_get_IsGrounded(uint64 this) : bool
#   LaunchClamp_Release(uint64 this)
#   LaunchClamp_get_Part(uint64 this) : uint64
#   Light_get_Part(uint64 this) : uint64
#   Light_get_Active(uint64 this) : bool
#   Light_set_Active(uint64 this, bool value)
#   Light_get_Color(uint64 this) : KRPC.Tuple
#   Light_set_Color(uint64 this, KRPC.Tuple value)
#   Light_get_PowerUsage(uint64 this) : float
#   Module_HasField(uint64 this, string name) : bool
#   Module_GetField(uint64 this, string name) : string
#   Module_SetFieldInt(uint64 this, string name, int32 value)
#   Module_SetFieldFloat(uint64 this, string name, float value)
#   Module_SetFieldString(uint64 this, string name, string value)
#   Module_ResetField(uint64 this, string name)
#   Module_HasEvent(uint64 this, string name) : bool
#   Module_TriggerEvent(uint64 this, string name)
#   Module_HasAction(uint64 this, string name) : bool
#   Module_SetAction(uint64 this, string name, bool value)
#   Module_get_Name(uint64 this) : string
#   Module_get_Part(uint64 this) : uint64
#   Module_get_Fields(uint64 this) : KRPC.Dictionary
#   Module_get_Events(uint64 this) : KRPC.List
#   Module_get_Actions(uint64 this) : KRPC.List
#   Parachute_Deploy(uint64 this)
#   Parachute_get_Part(uint64 this) : uint64
#   Parachute_get_Deployed(uint64 this) : bool
#   Parachute_get_State(uint64 this) : int32
#   Parachute_get_DeployAltitude(uint64 this) : float
#   Parachute_set_DeployAltitude(uint64 this, float value)
#   Parachute_get_DeployMinPressure(uint64 this) : float
#   Parachute_set_DeployMinPressure(uint64 this, float value)
#   Part_Position(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_CenterOfMass(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_BoundingBox(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_Direction(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_Velocity(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_Rotation(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Part_AddForce(uint64 this, KRPC.Tuple force, KRPC.Tuple position, uint64 referenceFrame) : uint64
#   Part_InstantaneousForce(uint64 this, KRPC.Tuple force, KRPC.Tuple position, uint64 referenceFrame)
#   Part_get_Name(uint64 this) : string
#   Part_get_Title(uint64 this) : string
#   Part_get_Tag(uint64 this) : string
#   Part_set_Tag(uint64 this, string value)
#   Part_get_Cost(uint64 this) : double
#   Part_get_Vessel(uint64 this) : uint64
#   Part_get_Parent(uint64 this) : uint64
#   Part_get_Children(uint64 this) : KRPC.List
#   Part_get_AxiallyAttached(uint64 this) : bool
#   Part_get_RadiallyAttached(uint64 this) : bool
#   Part_get_Stage(uint64 this) : int32
#   Part_get_DecoupleStage(uint64 this) : int32
#   Part_get_Massless(uint64 this) : bool
#   Part_get_Mass(uint64 this) : double
#   Part_get_DryMass(uint64 this) : double
#   Part_get_Shielded(uint64 this) : bool
#   Part_get_DynamicPressure(uint64 this) : float
#   Part_get_ImpactTolerance(uint64 this) : double
#   Part_get_Temperature(uint64 this) : double
#   Part_get_SkinTemperature(uint64 this) : double
#   Part_get_MaxTemperature(uint64 this) : double
#   Part_get_MaxSkinTemperature(uint64 this) : double
#   Part_get_ThermalMass(uint64 this) : float
#   Part_get_ThermalSkinMass(uint64 this) : float
#   Part_get_ThermalResourceMass(uint64 this) : float
#   Part_get_ThermalInternalFlux(uint64 this) : float
#   Part_get_ThermalConductionFlux(uint64 this) : float
#   Part_get_ThermalConvectionFlux(uint64 this) : float
#   Part_get_ThermalRadiationFlux(uint64 this) : float
#   Part_get_ThermalSkinToInternalFlux(uint64 this) : float
#   Part_get_Resources(uint64 this) : uint64
#   Part_get_Crossfeed(uint64 this) : bool
#   Part_get_IsFuelLine(uint64 this) : bool
#   Part_get_FuelLinesFrom(uint64 this) : KRPC.List
#   Part_get_FuelLinesTo(uint64 this) : KRPC.List
#   Part_get_Modules(uint64 this) : KRPC.List
#   Part_get_CargoBay(uint64 this) : uint64
#   Part_get_ControlSurface(uint64 this) : uint64
#   Part_get_Decoupler(uint64 this) : uint64
#   Part_get_DockingPort(uint64 this) : uint64
#   Part_get_Engine(uint64 this) : uint64
#   Part_get_Experiment(uint64 this) : uint64
#   Part_get_Fairing(uint64 this) : uint64
#   Part_get_Intake(uint64 this) : uint64
#   Part_get_LandingGear(uint64 this) : uint64
#   Part_get_LandingLeg(uint64 this) : uint64
#   Part_get_LaunchClamp(uint64 this) : uint64
#   Part_get_Light(uint64 this) : uint64
#   Part_get_Parachute(uint64 this) : uint64
#   Part_get_Radiator(uint64 this) : uint64
#   Part_get_RCS(uint64 this) : uint64
#   Part_get_ReactionWheel(uint64 this) : uint64
#   Part_get_ResourceConverter(uint64 this) : uint64
#   Part_get_ResourceHarvester(uint64 this) : uint64
#   Part_get_Sensor(uint64 this) : uint64
#   Part_get_SolarPanel(uint64 this) : uint64
#   Part_get_MomentOfInertia(uint64 this) : KRPC.Tuple
#   Part_get_InertiaTensor(uint64 this) : KRPC.List
#   Part_get_ReferenceFrame(uint64 this) : uint64
#   Part_get_CenterOfMassReferenceFrame(uint64 this) : uint64
#   Parts_WithName(uint64 this, string name) : KRPC.List
#   Parts_WithTitle(uint64 this, string title) : KRPC.List
#   Parts_WithTag(uint64 this, string tag) : KRPC.List
#   Parts_WithModule(uint64 this, string moduleName) : KRPC.List
#   Parts_InStage(uint64 this, int32 stage) : KRPC.List
#   Parts_InDecoupleStage(uint64 this, int32 stage) : KRPC.List
#   Parts_ModulesWithName(uint64 this, string moduleName) : KRPC.List
#   Parts_get_All(uint64 this) : KRPC.List
#   Parts_get_Root(uint64 this) : uint64
#   Parts_get_Controlling(uint64 this) : uint64
#   Parts_set_Controlling(uint64 this, uint64 value)
#   Parts_get_ControlSurfaces(uint64 this) : KRPC.List
#   Parts_get_CargoBays(uint64 this) : KRPC.List
#   Parts_get_Decouplers(uint64 this) : KRPC.List
#   Parts_get_DockingPorts(uint64 this) : KRPC.List
#   Parts_get_Engines(uint64 this) : KRPC.List
#   Parts_get_Experiments(uint64 this) : KRPC.List
#   Parts_get_Fairings(uint64 this) : KRPC.List
#   Parts_get_Intakes(uint64 this) : KRPC.List
#   Parts_get_LandingGear(uint64 this) : KRPC.List
#   Parts_get_LandingLegs(uint64 this) : KRPC.List
#   Parts_get_LaunchClamps(uint64 this) : KRPC.List
#   Parts_get_Lights(uint64 this) : KRPC.List
#   Parts_get_Parachutes(uint64 this) : KRPC.List
#   Parts_get_Radiators(uint64 this) : KRPC.List
#   Parts_get_RCS(uint64 this) : KRPC.List
#   Parts_get_ReactionWheels(uint64 this) : KRPC.List
#   Parts_get_ResourceConverters(uint64 this) : KRPC.List
#   Parts_get_ResourceHarvesters(uint64 this) : KRPC.List
#   Parts_get_Sensors(uint64 this) : KRPC.List
#   Parts_get_SolarPanels(uint64 this) : KRPC.List
#   Propellant_get_Name(uint64 this) : string
#   Propellant_get_CurrentAmount(uint64 this) : double
#   Propellant_get_CurrentRequirement(uint64 this) : double
#   Propellant_get_TotalResourceAvailable(uint64 this) : double
#   Propellant_get_TotalResourceCapacity(uint64 this) : double
#   Propellant_get_IgnoreForIsp(uint64 this) : bool
#   Propellant_get_IgnoreForThrustCurve(uint64 this) : bool
#   Propellant_get_DrawStackGauge(uint64 this) : bool
#   Propellant_get_IsDeprived(uint64 this) : bool
#   Propellant_get_Ratio(uint64 this) : float
#   RCS_get_Part(uint64 this) : uint64
#   RCS_get_Active(uint64 this) : bool
#   RCS_get_Enabled(uint64 this) : bool
#   RCS_set_Enabled(uint64 this, bool value)
#   RCS_get_PitchEnabled(uint64 this) : bool
#   RCS_set_PitchEnabled(uint64 this, bool value)
#   RCS_get_YawEnabled(uint64 this) : bool
#   RCS_set_YawEnabled(uint64 this, bool value)
#   RCS_get_RollEnabled(uint64 this) : bool
#   RCS_set_RollEnabled(uint64 this, bool value)
#   RCS_get_ForwardEnabled(uint64 this) : bool
#   RCS_set_ForwardEnabled(uint64 this, bool value)
#   RCS_get_UpEnabled(uint64 this) : bool
#   RCS_set_UpEnabled(uint64 this, bool value)
#   RCS_get_RightEnabled(uint64 this) : bool
#   RCS_set_RightEnabled(uint64 this, bool value)
#   RCS_get_AvailableTorque(uint64 this) : KRPC.Tuple
#   RCS_get_MaxThrust(uint64 this) : float
#   RCS_get_MaxVacuumThrust(uint64 this) : float
#   RCS_get_Thrusters(uint64 this) : KRPC.List
#   RCS_get_SpecificImpulse(uint64 this) : float
#   RCS_get_VacuumSpecificImpulse(uint64 this) : float
#   RCS_get_KerbinSeaLevelSpecificImpulse(uint64 this) : float
#   RCS_get_Propellants(uint64 this) : KRPC.List
#   RCS_get_PropellantRatios(uint64 this) : KRPC.Dictionary
#   RCS_get_HasFuel(uint64 this) : bool
#   Radiator_get_Part(uint64 this) : uint64
#   Radiator_get_Deployable(uint64 this) : bool
#   Radiator_get_Deployed(uint64 this) : bool
#   Radiator_set_Deployed(uint64 this, bool value)
#   Radiator_get_State(uint64 this) : int32
#   ReactionWheel_get_Part(uint64 this) : uint64
#   ReactionWheel_get_Active(uint64 this) : bool
#   ReactionWheel_set_Active(uint64 this, bool value)
#   ReactionWheel_get_Broken(uint64 this) : bool
#   ReactionWheel_get_AvailableTorque(uint64 this) : KRPC.Tuple
#   ReactionWheel_get_MaxTorque(uint64 this) : KRPC.Tuple
#   ResourceConverter_Active(uint64 this, int32 index) : bool
#   ResourceConverter_Name(uint64 this, int32 index) : string
#   ResourceConverter_Start(uint64 this, int32 index)
#   ResourceConverter_Stop(uint64 this, int32 index)
#   ResourceConverter_State(uint64 this, int32 index) : int32
#   ResourceConverter_StatusInfo(uint64 this, int32 index) : string
#   ResourceConverter_Inputs(uint64 this, int32 index) : KRPC.List
#   ResourceConverter_Outputs(uint64 this, int32 index) : KRPC.List
#   ResourceConverter_get_Part(uint64 this) : uint64
#   ResourceConverter_get_Count(uint64 this) : int32
#   ResourceHarvester_get_Part(uint64 this) : uint64
#   ResourceHarvester_get_State(uint64 this) : int32
#   ResourceHarvester_get_Deployed(uint64 this) : bool
#   ResourceHarvester_set_Deployed(uint64 this, bool value)
#   ResourceHarvester_get_Active(uint64 this) : bool
#   ResourceHarvester_set_Active(uint64 this, bool value)
#   ResourceHarvester_get_ExtractionRate(uint64 this) : float
#   ResourceHarvester_get_ThermalEfficiency(uint64 this) : float
#   ResourceHarvester_get_CoreTemperature(uint64 this) : float
#   ResourceHarvester_get_OptimumCoreTemperature(uint64 this) : float
#   ScienceData_get_DataAmount(uint64 this) : float
#   ScienceData_get_ScienceValue(uint64 this) : float
#   ScienceData_get_TransmitValue(uint64 this) : float
#   ScienceSubject_get_Science(uint64 this) : float
#   ScienceSubject_get_ScienceCap(uint64 this) : float
#   ScienceSubject_get_IsComplete(uint64 this) : bool
#   ScienceSubject_get_DataScale(uint64 this) : float
#   ScienceSubject_get_ScientificValue(uint64 this) : float
#   ScienceSubject_get_SubjectValue(uint64 this) : float
#   ScienceSubject_get_Title(uint64 this) : string
#   Sensor_get_Part(uint64 this) : uint64
#   Sensor_get_Active(uint64 this) : bool
#   Sensor_set_Active(uint64 this, bool value)
#   Sensor_get_Value(uint64 this) : string
#   SolarPanel_get_Part(uint64 this) : uint64
#   SolarPanel_get_Deployed(uint64 this) : bool
#   SolarPanel_set_Deployed(uint64 this, bool value)
#   SolarPanel_get_State(uint64 this) : int32
#   SolarPanel_get_EnergyFlow(uint64 this) : float
#   SolarPanel_get_SunExposure(uint64 this) : float
#   Thruster_ThrustPosition(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Thruster_ThrustDirection(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Thruster_InitialThrustPosition(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Thruster_InitialThrustDirection(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Thruster_GimbalPosition(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Thruster_get_Part(uint64 this) : uint64
#   Thruster_get_ThrustReferenceFrame(uint64 this) : uint64
#   Thruster_get_Gimballed(uint64 this) : bool
#   Thruster_get_GimbalAngle(uint64 this) : KRPC.Tuple
#   ReferenceFrame_CreateRelative(uint64 referenceFrame, KRPC.Tuple position, KRPC.Tuple rotation, KRPC.Tuple velocity, KRPC.Tuple angularVelocity) : uint64
#   ReferenceFrame_CreateHybrid(uint64 position, uint64 rotation, uint64 velocity, uint64 angularVelocity) : uint64
#   Resource_get_Name(uint64 this) : string
#   Resource_get_Part(uint64 this) : uint64
#   Resource_get_Max(uint64 this) : float
#   Resource_get_Amount(uint64 this) : float
#   Resource_get_Density(uint64 this) : float
#   Resource_get_FlowMode(uint64 this) : int32
#   Resource_get_Enabled(uint64 this) : bool
#   Resource_set_Enabled(uint64 this, bool value)
#   ResourceTransfer_Start(uint64 fromPart, uint64 toPart, string resource, float maxAmount) : uint64
#   ResourceTransfer_get_Complete(uint64 this) : bool
#   ResourceTransfer_get_Amount(uint64 this) : float
#   Resources_WithResource(uint64 this, string name) : KRPC.List
#   Resources_HasResource(uint64 this, string name) : bool
#   Resources_Max(uint64 this, string name) : float
#   Resources_Amount(uint64 this, string name) : float
#   Resources_Density(string name) : float
#   Resources_FlowMode(string name) : int32
#   Resources_get_All(uint64 this) : KRPC.List
#   Resources_get_Names(uint64 this) : KRPC.List
#   Resources_get_Enabled(uint64 this) : bool
#   Resources_set_Enabled(uint64 this, bool value)
#   Vessel_Recover(uint64 this)
#   Vessel_Flight(uint64 this, uint64 referenceFrame) : uint64
#   Vessel_ResourcesInDecoupleStage(uint64 this, int32 stage, bool cumulative) : uint64
#   Vessel_Position(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_BoundingBox(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_Velocity(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_Rotation(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_Direction(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_AngularVelocity(uint64 this, uint64 referenceFrame) : KRPC.Tuple
#   Vessel_get_Name(uint64 this) : string
#   Vessel_set_Name(uint64 this, string value)
#   Vessel_get_Type(uint64 this) : int32
#   Vessel_set_Type(uint64 this, int32 value)
#   Vessel_get_Situation(uint64 this) : int32
#   Vessel_get_Recoverable(uint64 this) : bool
#   Vessel_get_MET(uint64 this) : double
#   Vessel_get_Biome(uint64 this) : string
#   Vessel_get_Orbit(uint64 this) : uint64

@doc ~S"""
Returns a Control object that can be used to manipulate the vessel’s control inputs. For example, its pitch/yaw/roll controls, RCS and thrust.

## RPC signature
Vessel_get_Control(uint64 this) : uint64
"""
def vessel_get_control(conn, vessel_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "Vessel_get_Control", [{vessel_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      {control_id, _} = :gpb.decode_type(:uint64, return_value, nil)
      {:ok, control_id, time}
    {:error, _reason, _time} = error ->
      error
  end
end

#

@doc ~S"""
Gets an AutoPilot object, that can be used to perform simple auto-piloting of the vessel.

## RPC signature
Vessel_get_AutoPilot(uint64 this) : uint64
"""
def vessel_get_autopilot(conn, vessel_id) do
  case Jooce.Connection.call_rpc(conn, "SpaceCenter", "Vessel_get_AutoPilot", [{vessel_id, :uint64, nil}]) do
    {:ok, return_value, time} ->
      {autopilot_id, _} = :gpb.decode_type(:uint64, return_value, nil)
      {:ok, autopilot_id, time}
    {:error, _reason, _time} = error ->
      error
  end
end

#   Vessel_get_Resources(uint64 this) : uint64
#   Vessel_get_Parts(uint64 this) : uint64
#   Vessel_get_Mass(uint64 this) : float
#   Vessel_get_DryMass(uint64 this) : float
#   Vessel_get_Thrust(uint64 this) : float
#   Vessel_get_AvailableThrust(uint64 this) : float
#   Vessel_get_MaxThrust(uint64 this) : float
#   Vessel_get_MaxVacuumThrust(uint64 this) : float
#   Vessel_get_SpecificImpulse(uint64 this) : float
#   Vessel_get_VacuumSpecificImpulse(uint64 this) : float
#   Vessel_get_KerbinSeaLevelSpecificImpulse(uint64 this) : float
#   Vessel_get_MomentOfInertia(uint64 this) : KRPC.Tuple
#   Vessel_get_InertiaTensor(uint64 this) : KRPC.List
#   Vessel_get_AvailableTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_AvailableReactionWheelTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_AvailableRCSTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_AvailableEngineTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_AvailableControlSurfaceTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_AvailableOtherTorque(uint64 this) : KRPC.Tuple
#   Vessel_get_ReferenceFrame(uint64 this) : uint64
#   Vessel_get_OrbitalReferenceFrame(uint64 this) : uint64
#   Vessel_get_SurfaceReferenceFrame(uint64 this) : uint64
#   Vessel_get_SurfaceVelocityReferenceFrame(uint64 this) : uint64
#   Waypoint_Remove(uint64 this)
#   Waypoint_get_Body(uint64 this) : uint64
#   Waypoint_set_Body(uint64 this, uint64 value)
#   Waypoint_get_Name(uint64 this) : string
#   Waypoint_set_Name(uint64 this, string value)
#   Waypoint_get_Color(uint64 this) : int32
#   Waypoint_set_Color(uint64 this, int32 value)
#   Waypoint_get_Icon(uint64 this) : string
#   Waypoint_set_Icon(uint64 this, string value)
#   Waypoint_get_Latitude(uint64 this) : double
#   Waypoint_set_Latitude(uint64 this, double value)
#   Waypoint_get_Longitude(uint64 this) : double
#   Waypoint_set_Longitude(uint64 this, double value)
#   Waypoint_get_MeanAltitude(uint64 this) : double
#   Waypoint_set_MeanAltitude(uint64 this, double value)
#   Waypoint_get_SurfaceAltitude(uint64 this) : double
#   Waypoint_set_SurfaceAltitude(uint64 this, double value)
#   Waypoint_get_BedrockAltitude(uint64 this) : double
#   Waypoint_set_BedrockAltitude(uint64 this, double value)
#   Waypoint_get_NearSurface(uint64 this) : bool
#   Waypoint_get_Grounded(uint64 this) : bool
#   Waypoint_get_Index(uint64 this) : int32
#   Waypoint_get_Clustered(uint64 this) : bool
#   Waypoint_get_HasContract(uint64 this) : bool
#   Waypoint_get_ContractId(uint64 this) : int64
#   WaypointManager_AddWaypoint(uint64 this, double latitude, double longitude, uint64 body, string name) : uint64
#   WaypointManager_get_Waypoints(uint64 this) : KRPC.List
#   WaypointManager_get_Icons(uint64 this) : KRPC.List
#   WaypointManager_get_Colors(uint64 this) : KRPC.Dictionary

end
