tool
extends EditorPlugin

const numFieldNodeScript:Script = preload("res://addons/fight_data_creator/custom_nodes/NumFieldNode.gd")
const textFieldNodeScript:Script = preload("res://addons/fight_data_creator/custom_nodes/TextFieldNode.gd")
const floatLineEdit:Script = preload("res://addons/fight_data_creator/custom_nodes/FloatLineEdit.gd")
const CustomInspectorEditor = preload("res://addons/fight_data_creator/inspector/MyInspectorPlugin.gd")

var attack_data:Popup
var inspector_plugin

func _enter_tree():
	add_custom_type("NumFieldEditor", "VBoxContainer", numFieldNodeScript, null)
	add_custom_type("TextFieldEditor", "VBoxContainer", textFieldNodeScript, null)
	add_custom_type("FloatLineEdit", "LineEdit", floatLineEdit, null)

	attack_data = preload("res://addons/fight_data_creator/scenes/AttackEditorByFrames.tscn").instance()	
	get_editor_interface().add_child(attack_data)
	
	add_tool_menu_item("Attack FrameData", self, "_show_popup")
	
	inspector_plugin = CustomInspectorEditor.new()
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_custom_type("NumFieldEditor")
	remove_custom_type("TextFieldEditor")
	remove_custom_type("FloatLineEdit")
	remove_tool_menu_item("Attack FrameData")
	attack_data.queue_free()
	
	remove_inspector_plugin(inspector_plugin)

func _show_popup(params):
	attack_data.popup_centered()
