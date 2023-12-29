extends AcceptDialog
tool

signal box_data_changed(value)

export(NodePath) var editLineNamePath
export(NodePath) var editLinePositionXPath
export(NodePath) var editLinePositionYPath
export(NodePath) var editLineSizeXPath
export(NodePath) var editLineSizeYPath

onready var edit_line_name = get_node(editLineNamePath)
onready var edit_line_pos_x = get_node(editLinePositionXPath)
onready var edit_line_pos_y = get_node(editLinePositionYPath)
onready var edit_line_size_x = get_node(editLineSizeXPath)
onready var edit_line_size_y = get_node(editLineSizeYPath)

var boxData:PlayerResource.Box

func _on_BoxEditorItem_confirmed():
	emit_signal("box_data_changed", boxData)

func _on_NameLineEdit_text_changed(new_text:String):
	boxData.name = new_text

func _on_LineEditOriginX_text_changed(new_text:String):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		edit_line_pos_x.modulate = Color.white
		boxData.rect.ox = new_text
	else:
		edit_line_pos_x.modulate = Color.red
		boxData.rect.ox = '0'

func _on_LineEditSizeX_text_changed(new_text:String):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		edit_line_size_x.modulate = Color.white
		boxData.rect.sx = new_text
	else:
		edit_line_size_x.modulate = Color.red
		boxData.rect.sx = '0'

func _on_LineEditOriginY_text_changed(new_text:String):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		edit_line_pos_y.modulate = Color.white
		boxData.rect.oy = new_text
	else:
		edit_line_pos_y.modulate = Color.red
		boxData.rect.oy = '0'

func _on_LineEditSizeY_text_changed(new_text:String):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		edit_line_size_y.modulate = Color.white
		boxData.rect.sy = new_text
	else:
		edit_line_size_y.modulate = Color.red
		boxData.rect.sy = '0'

func _on_BoxEditorItem_about_to_show():
	edit_line_name.text = boxData.name
	# Fill data if empty
	if boxData.rect.ox.empty():
		boxData.rect.ox = '0'
	if boxData.rect.oy.empty():
		boxData.rect.oy = '0'
	if boxData.rect.sx.empty():
		boxData.rect.sx = '0'
	if boxData.rect.sy.empty():
		boxData.rect.sy = '0'
	edit_line_pos_x.text = boxData.rect.ox
	edit_line_pos_y.text = boxData.rect.oy
	edit_line_size_x.text = boxData.rect.sx
	edit_line_size_y.text = boxData.rect.sy
