extends VBoxContainer
tool

signal value_changed(value)

var label:Label = Label.new()
var value = LineEdit.new()
var warning = Label.new()
var checked = true
export(String) var text setget label_set_text

func _ready():
	for ch in get_children():
		remove_child(ch)
	
	add_child(label)
	add_child(value)
	add_child(warning)
	
	value.text = "0"
	warning.text = "Value is not a valid float"
	warning.visible = false
	
	value.connect("text_entered", self, "_check_value_is_valid")
	value.connect("text_changed", self, "_on_value_change")
	
	value.connect("focus_exited", self, "_when_focus_exited")


func _check_value_is_valid(text:String):
	checked = true
	if(text.is_valid_float()):
		warning.visible = false
		value.modulate = Color.white
		emit_signal("value_changed", text)
	else:
		warning.visible = true
		value.modulate = Color.red
		
func _on_value_change(text:String):
	checked = false
	
func _when_focus_exited():
	if not checked:
		_check_value_is_valid(value.text)

func label_set_text(_text):
	text = _text
	label.text = text
