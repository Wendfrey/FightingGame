extends VBoxContainer
tool

signal send_new_value(value)

var label = Label.new()
var value = SpinBox.new()
export(String) var text setget updateLabel

func _ready():
	for i in get_children():
		remove_child(i)
	add_child(label)
	add_child(value)
	value.connect("value_changed", self, "value_update")
	
	value.size_flags_horizontal = size_flags_horizontal
	value.size_flags_vertical = size_flags_vertical

func updateLabel(value): 
	text = value
	label.text = value
	
func value_update(new_int):
	emit_signal("send_new_value", int(new_int))
