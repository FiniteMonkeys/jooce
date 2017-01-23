# Enumerations:
# Procedures:
#   ServoGroups(uint64 vessel) : KRPC.List
#   ServoGroupWithName(uint64 vessel, string name) : uint64
#   ServoWithName(uint64 vessel, string name) : uint64
#   get_Available() : bool
#   Servo_MoveRight(uint64 this)
#   Servo_MoveLeft(uint64 this)
#   Servo_MoveCenter(uint64 this)
#   Servo_MoveNextPreset(uint64 this)
#   Servo_MovePrevPreset(uint64 this)
#   Servo_MoveTo(uint64 this, float position, float speed)
#   Servo_Stop(uint64 this)
#   Servo_get_Name(uint64 this) : string
#   Servo_set_Name(uint64 this, string value)
#   Servo_get_Part(uint64 this) : uint64
#   Servo_set_Highlight(uint64 this, bool value)
#   Servo_get_Position(uint64 this) : float
#   Servo_get_MinConfigPosition(uint64 this) : float
#   Servo_get_MaxConfigPosition(uint64 this) : float
#   Servo_get_MinPosition(uint64 this) : float
#   Servo_set_MinPosition(uint64 this, float value)
#   Servo_get_MaxPosition(uint64 this) : float
#   Servo_set_MaxPosition(uint64 this, float value)
#   Servo_get_ConfigSpeed(uint64 this) : float
#   Servo_get_Speed(uint64 this) : float
#   Servo_set_Speed(uint64 this, float value)
#   Servo_get_CurrentSpeed(uint64 this) : float
#   Servo_set_CurrentSpeed(uint64 this, float value)
#   Servo_get_Acceleration(uint64 this) : float
#   Servo_set_Acceleration(uint64 this, float value)
#   Servo_get_IsMoving(uint64 this) : bool
#   Servo_get_IsFreeMoving(uint64 this) : bool
#   Servo_get_IsLocked(uint64 this) : bool
#   Servo_set_IsLocked(uint64 this, bool value)
#   Servo_get_IsAxisInverted(uint64 this) : bool
#   Servo_set_IsAxisInverted(uint64 this, bool value)
#   ServoGroup_ServoWithName(uint64 this, string name) : uint64
#   ServoGroup_MoveRight(uint64 this)
#   ServoGroup_MoveLeft(uint64 this)
#   ServoGroup_MoveCenter(uint64 this)
#   ServoGroup_MoveNextPreset(uint64 this)
#   ServoGroup_MovePrevPreset(uint64 this)
#   ServoGroup_Stop(uint64 this)
#   ServoGroup_get_Name(uint64 this) : string
#   ServoGroup_set_Name(uint64 this, string value)
#   ServoGroup_get_ForwardKey(uint64 this) : string
#   ServoGroup_set_ForwardKey(uint64 this, string value)
#   ServoGroup_get_ReverseKey(uint64 this) : string
#   ServoGroup_set_ReverseKey(uint64 this, string value)
#   ServoGroup_get_Speed(uint64 this) : float
#   ServoGroup_set_Speed(uint64 this, float value)
#   ServoGroup_get_Expanded(uint64 this) : bool
#   ServoGroup_set_Expanded(uint64 this, bool value)
#   ServoGroup_get_Servos(uint64 this) : KRPC.List
#   ServoGroup_get_Parts(uint64 this) : KRPC.List
