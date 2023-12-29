extends AcceptDialog
tool

signal new_property(name, type)
signal modify_property(old_name, name, type)

onready var propertyNameEdit = $VBoxContainer/AddPropertyEdit
onready var propertyTypeMenu = $VBoxContainer/TypeMenuButton
onready var propertyTypePopup = propertyTypeMenu.get_popup()

var modify_property: bool = false
var old_name:String = ""
var type = ""

func _ready():
	propertyTypePopup.connect("index_pressed", self, "_on_property_type_selected")

func modify_property(_name, _type):
	modify_property = true
	old_name = _name
	type = _type
	window_title = "Modify property"

func new_property():
	modify_property = false
	old_name = ""
	type = ""
	window_title = "Add property"

func _on_AddPropertyDialog_confirmed():
	var _pname = propertyNameEdit.text.strip_edges()
	if not _pname.empty() and not type.empty():
		if(modify_property):
			emit_signal("modify_property", old_name, _pname, type)
		else:
			emit_signal("new_property", _pname, type)

func _on_property_type_selected(index):
	type = propertyTypePopup.get_item_text(index)
	propertyTypeMenu.text = type


func _on_AddPropertyDialog_about_to_show():
	propertyNameEdit.text = old_name
	if type.empty():
		propertyTypeMenu.text = "Type"
	else:
		propertyTypeMenu.text = type
