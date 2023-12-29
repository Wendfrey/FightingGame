extends Button
tool

const visibleTexture = preload("res://addons/fight_data_creator/imgs/godot_visibility_icon.svg")
const invisibleTexture = preload("res://addons/fight_data_creator/imgs/godot_no_visibility_icon.svg")

export(NodePath) var foldingNode

func _ready():
	_on_FoldPropertiesButton_toggled(pressed)

func _on_FoldPropertiesButton_toggled(button_pressed):
	get_node(foldingNode).visible = button_pressed
	_set_icon_visibility(button_pressed)

func _set_icon_visibility(button_pressed):
	icon = visibleTexture if button_pressed else invisibleTexture
