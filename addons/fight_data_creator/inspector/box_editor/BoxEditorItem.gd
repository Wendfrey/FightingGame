extends VBoxContainer
tool

signal edit_box_data(index)

onready var sizeValueLabel = $HBoxContainer2/SizeValue
onready var nameValueLabel = $HBoxContainer/NameValue

func set_data(data:PlayerResource.Box):
	sizeValueLabel.text = "Position: ({ox}, {oy}) - Size: ({sx}, {sy})".format(
		{
			"ox": data.rect.ox,
			"oy": data.rect.oy,
			"sx": data.rect.sx,
			"sy": data.rect.sy
		}
	)
	nameValueLabel.text = data.name

func _on_Button_pressed():
	emit_signal("edit_box_data", get_index())
