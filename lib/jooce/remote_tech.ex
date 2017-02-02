# Enumerations:
#   Target
#     0 = ActiveVessel
#     1 = CelestialBody
#     2 = GroundStation
#     3 = Vessel
#     4 = None
# Procedures:
#   Comms(uint64 vessel) : uint64
#   Antenna(uint64 part) : uint64
#   get_Available() : bool
#   get_GroundStations() : KRPC.List
#   Antenna_get_Part(uint64 this) : uint64
#   Antenna_get_HasConnection(uint64 this) : bool
#   Antenna_get_Target(uint64 this) : int32
#   Antenna_set_Target(uint64 this, int32 value)
#   Antenna_get_TargetBody(uint64 this) : uint64
#   Antenna_set_TargetBody(uint64 this, uint64 value)
#   Antenna_get_TargetGroundStation(uint64 this) : string
#   Antenna_set_TargetGroundStation(uint64 this, string value)
#   Antenna_get_TargetVessel(uint64 this) : uint64
#   Antenna_set_TargetVessel(uint64 this, uint64 value)
#   Comms_SignalDelayToVessel(uint64 this, uint64 other) : double
#   Comms_get_Vessel(uint64 this) : uint64
#   Comms_get_HasLocalControl(uint64 this) : bool
#   Comms_get_HasFlightComputer(uint64 this) : bool
#   Comms_get_HasConnection(uint64 this) : bool
#   Comms_get_HasConnectionToGroundStation(uint64 this) : bool
#   Comms_get_SignalDelay(uint64 this) : double
#   Comms_get_SignalDelayToGroundStation(uint64 this) : double
#   Comms_get_Antennas(uint64 this) : KRPC.List
