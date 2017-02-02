# Enumerations:
#   AlarmAction
#     0 = DoNothing
#     1 = DoNothingDeleteWhenPassed
#     2 = KillWarp
#     3 = KillWarpOnly
#     4 = MessageOnly
#     5 = PauseGame
#   AlarmType
#     0 = Raw
#     1 = Maneuver
#     2 = ManeuverAuto
#     3 = Apoapsis
#     4 = Periapsis
#     5 = AscendingNode
#     6 = DescendingNode
#     7 = Closest
#     8 = Contract
#     9 = ContractAuto
#     10 = Crew
#     11 = Distance
#     12 = EarthTime
#     13 = LaunchRendevous
#     14 = SOIChange
#     15 = SOIChangeAuto
#     16 = Transfer
#     17 = TransferModelled
# Procedures:
#   AlarmWithName(string name) : uint64
#   AlarmsWithType(int32 type) : KRPC.List
#   CreateAlarm(int32 type, string name, double ut) : uint64
#   get_Available() : bool
#   get_Alarms() : KRPC.List
#   Alarm_Remove(uint64 this)
#   Alarm_get_Action(uint64 this) : int32
#   Alarm_set_Action(uint64 this, int32 value)
#   Alarm_get_Margin(uint64 this) : double
#   Alarm_set_Margin(uint64 this, double value)
#   Alarm_get_Time(uint64 this) : double
#   Alarm_set_Time(uint64 this, double value)
#   Alarm_get_Type(uint64 this) : int32
#   Alarm_get_ID(uint64 this) : string
#   Alarm_get_Name(uint64 this) : string
#   Alarm_set_Name(uint64 this, string value)
#   Alarm_get_Notes(uint64 this) : string
#   Alarm_set_Notes(uint64 this, string value)
#   Alarm_get_Remaining(uint64 this) : double
#   Alarm_get_Repeat(uint64 this) : bool
#   Alarm_set_Repeat(uint64 this, bool value)
#   Alarm_get_RepeatPeriod(uint64 this) : double
#   Alarm_set_RepeatPeriod(uint64 this, double value)
#   Alarm_get_Vessel(uint64 this) : uint64
#   Alarm_set_Vessel(uint64 this, uint64 value)
#   Alarm_get_XferOriginBody(uint64 this) : uint64
#   Alarm_set_XferOriginBody(uint64 this, uint64 value)
#   Alarm_get_XferTargetBody(uint64 this) : uint64
#   Alarm_set_XferTargetBody(uint64 this, uint64 value)
