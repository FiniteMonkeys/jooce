# Enumerations:
# Procedures:
#   AddLine(KRPC.Tuple start, KRPC.Tuple end, uint64 referenceFrame, bool visible) : uint64
#   AddDirection(KRPC.Tuple direction, uint64 referenceFrame, float length, bool visible) : uint64
#   AddPolygon(KRPC.List vertices, uint64 referenceFrame, bool visible) : uint64
#   AddText(string text, uint64 referenceFrame, KRPC.Tuple position, KRPC.Tuple rotation, bool visible) : uint64
#   Clear(bool clientOnly)
#   Line_Remove(uint64 this)
#   Line_get_Start(uint64 this) : KRPC.Tuple
#   Line_set_Start(uint64 this, KRPC.Tuple value)
#   Line_get_End(uint64 this) : KRPC.Tuple
#   Line_set_End(uint64 this, KRPC.Tuple value)
#   Line_get_Color(uint64 this) : KRPC.Tuple
#   Line_set_Color(uint64 this, KRPC.Tuple value)
#   Line_get_Thickness(uint64 this) : float
#   Line_set_Thickness(uint64 this, float value)
#   Line_get_ReferenceFrame(uint64 this) : uint64
#   Line_set_ReferenceFrame(uint64 this, uint64 value)
#   Line_get_Visible(uint64 this) : bool
#   Line_set_Visible(uint64 this, bool value)
#   Line_get_Material(uint64 this) : string
#   Line_set_Material(uint64 this, string value)
#   Polygon_Remove(uint64 this)
#   Polygon_get_Vertices(uint64 this) : KRPC.List
#   Polygon_set_Vertices(uint64 this, KRPC.List value)
#   Polygon_get_Color(uint64 this) : KRPC.Tuple
#   Polygon_set_Color(uint64 this, KRPC.Tuple value)
#   Polygon_get_Thickness(uint64 this) : float
#   Polygon_set_Thickness(uint64 this, float value)
#   Polygon_get_ReferenceFrame(uint64 this) : uint64
#   Polygon_set_ReferenceFrame(uint64 this, uint64 value)
#   Polygon_get_Visible(uint64 this) : bool
#   Polygon_set_Visible(uint64 this, bool value)
#   Polygon_get_Material(uint64 this) : string
#   Polygon_set_Material(uint64 this, string value)
#   Text_Remove(uint64 this)
#   Text_get_Position(uint64 this) : KRPC.Tuple
#   Text_set_Position(uint64 this, KRPC.Tuple value)
#   Text_get_Rotation(uint64 this) : KRPC.Tuple
#   Text_set_Rotation(uint64 this, KRPC.Tuple value)
#   Text_get_AvailableFonts(uint64 this) : KRPC.List
#   Text_get_Content(uint64 this) : string
#   Text_set_Content(uint64 this, string value)
#   Text_get_Font(uint64 this) : string
#   Text_set_Font(uint64 this, string value)
#   Text_get_Size(uint64 this) : int32
#   Text_set_Size(uint64 this, int32 value)
#   Text_get_CharacterSize(uint64 this) : float
#   Text_set_CharacterSize(uint64 this, float value)
#   Text_get_Style(uint64 this) : int32
#   Text_set_Style(uint64 this, int32 value)
#   Text_get_Alignment(uint64 this) : int32
#   Text_set_Alignment(uint64 this, int32 value)
#   Text_get_LineSpacing(uint64 this) : float
#   Text_set_LineSpacing(uint64 this, float value)
#   Text_get_Anchor(uint64 this) : int32
#   Text_set_Anchor(uint64 this, int32 value)
#   Text_get_Color(uint64 this) : KRPC.Tuple
#   Text_set_Color(uint64 this, KRPC.Tuple value)
#   Text_get_ReferenceFrame(uint64 this) : uint64
#   Text_set_ReferenceFrame(uint64 this, uint64 value)
#   Text_get_Visible(uint64 this) : bool
#   Text_set_Visible(uint64 this, bool value)
#   Text_get_Material(uint64 this) : string
#   Text_set_Material(uint64 this, string value)
