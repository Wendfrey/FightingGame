extends HBoxContainer
tool

signal remove_property(property)
signal edit_property(property)

var text setget _on_text_set
var type setget _on_type_set

onready var propertyName = $PropertyName
onready var propertyType = $PropertyType

func _on_ModifyButton_pressed():
	emit_signal("edit_property", propertyName.text)


func _on_RemoveButton_pressed():
	emit_signal("remove_property", propertyName.text)
	queue_free()

func _on_text_set(n_text):
	text = n_text
	propertyName.text = n_text
	
func _on_type_set(n_type):
	type = n_type
	propertyType.text = n_type
