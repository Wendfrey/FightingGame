extends LineEdit
tool

signal valid_float(_float)

var last_float: float = 0

func _ready():
	connect("text_changed", self, "_on_text_changed")
	
func _on_text_changed(new_text:String):
	if new_text.empty():
		new_text = "0"
	if (new_text.is_valid_float()):
		last_float = float(new_text)
		emit_signal("valid_float", last_float)
	else:
		text = str(last_float)
