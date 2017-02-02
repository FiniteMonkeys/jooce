# Enumerations:
#   FontStyle
#     0 = Normal
#     1 = Bold
#     2 = Italic
#     3 = BoldAndItalic
#   MessagePosition
#     0 = BottomCenter
#     1 = TopCenter
#     2 = TopLeft
#     3 = TopRight
#   TextAlignment
#     0 = Left
#     1 = Right
#     2 = Center
#   TextAnchor
#     0 = LowerCenter
#     1 = LowerLeft
#     2 = LowerRight
#     3 = MiddleCenter
#     4 = MiddleLeft
#     5 = MiddleRight
#     6 = UpperCenter
#     7 = UpperLeft
#     8 = UpperRight
# Procedures:
#   AddCanvas() : uint64
#   Message(string content, float duration, int32 position)
#   Clear(bool clientOnly)
#   get_StockCanvas() : uint64
#   Button_Remove(uint64 this)
#   Button_get_RectTransform(uint64 this) : uint64
#   Button_get_Text(uint64 this) : uint64
#   Button_get_Clicked(uint64 this) : bool
#   Button_set_Clicked(uint64 this, bool value)
#   Button_get_Visible(uint64 this) : bool
#   Button_set_Visible(uint64 this, bool value)
#   Canvas_AddPanel(uint64 this, bool visible) : uint64
#   Canvas_AddText(uint64 this, string content, bool visible) : uint64
#   Canvas_AddInputField(uint64 this, bool visible) : uint64
#   Canvas_AddButton(uint64 this, string content, bool visible) : uint64
#   Canvas_Remove(uint64 this)
#   Canvas_get_RectTransform(uint64 this) : uint64
#   Canvas_get_Visible(uint64 this) : bool
#   Canvas_set_Visible(uint64 this, bool value)
#   InputField_Remove(uint64 this)
#   InputField_get_RectTransform(uint64 this) : uint64
#   InputField_get_Value(uint64 this) : string
#   InputField_set_Value(uint64 this, string value)
#   InputField_get_Text(uint64 this) : uint64
#   InputField_get_Changed(uint64 this) : bool
#   InputField_set_Changed(uint64 this, bool value)
#   InputField_get_Visible(uint64 this) : bool
#   InputField_set_Visible(uint64 this, bool value)
#   Panel_AddPanel(uint64 this, bool visible) : uint64
#   Panel_AddText(uint64 this, string content, bool visible) : uint64
#   Panel_AddInputField(uint64 this, bool visible) : uint64
#   Panel_AddButton(uint64 this, string content, bool visible) : uint64
#   Panel_Remove(uint64 this)
#   Panel_get_RectTransform(uint64 this) : uint64
#   Panel_get_Visible(uint64 this) : bool
#   Panel_set_Visible(uint64 this, bool value)
#   RectTransform_get_Position(uint64 this) : KRPC.Tuple
#   RectTransform_set_Position(uint64 this, KRPC.Tuple value)
#   RectTransform_get_LocalPosition(uint64 this) : KRPC.Tuple
#   RectTransform_set_LocalPosition(uint64 this, KRPC.Tuple value)
#   RectTransform_get_Size(uint64 this) : KRPC.Tuple
#   RectTransform_set_Size(uint64 this, KRPC.Tuple value)
#   RectTransform_get_UpperRight(uint64 this) : KRPC.Tuple
#   RectTransform_set_UpperRight(uint64 this, KRPC.Tuple value)
#   RectTransform_get_LowerLeft(uint64 this) : KRPC.Tuple
#   RectTransform_set_LowerLeft(uint64 this, KRPC.Tuple value)
#   RectTransform_set_Anchor(uint64 this, KRPC.Tuple value)
#   RectTransform_get_AnchorMax(uint64 this) : KRPC.Tuple
#   RectTransform_set_AnchorMax(uint64 this, KRPC.Tuple value)
#   RectTransform_get_AnchorMin(uint64 this) : KRPC.Tuple
#   RectTransform_set_AnchorMin(uint64 this, KRPC.Tuple value)
#   RectTransform_get_Pivot(uint64 this) : KRPC.Tuple
#   RectTransform_set_Pivot(uint64 this, KRPC.Tuple value)
#   RectTransform_get_Rotation(uint64 this) : KRPC.Tuple
#   RectTransform_set_Rotation(uint64 this, KRPC.Tuple value)
#   RectTransform_get_Scale(uint64 this) : KRPC.Tuple
#   RectTransform_set_Scale(uint64 this, KRPC.Tuple value)
#   Text_Remove(uint64 this)
#   Text_get_RectTransform(uint64 this) : uint64
#   Text_get_AvailableFonts(uint64 this) : KRPC.List
#   Text_get_Content(uint64 this) : string
#   Text_set_Content(uint64 this, string value)
#   Text_get_Font(uint64 this) : string
#   Text_set_Font(uint64 this, string value)
#   Text_get_Size(uint64 this) : int32
#   Text_set_Size(uint64 this, int32 value)
#   Text_get_Style(uint64 this) : int32
#   Text_set_Style(uint64 this, int32 value)
#   Text_get_Alignment(uint64 this) : int32
#   Text_set_Alignment(uint64 this, int32 value)
#   Text_get_LineSpacing(uint64 this) : float
#   Text_set_LineSpacing(uint64 this, float value)
#   Text_get_Color(uint64 this) : KRPC.Tuple
#   Text_set_Color(uint64 this, KRPC.Tuple value)
#   Text_get_Visible(uint64 this) : bool
#   Text_set_Visible(uint64 this, bool value)
