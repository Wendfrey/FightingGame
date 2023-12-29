extends FrameEditorBase
tool

onready var frameStartSpinbox = $HBoxContainer/CenterContainer/VBoxContainer/StartFrameSpinBox
onready var frameLengthSpinbox = $HBoxContainer/CenterContainer2/VBoxContainer/FrameDurationSpinBox
onready var framedataName = $FrameDataName

func _on_StartFrameSpinBox_value_changed(value):
	emit_signal("frame_start_changed", value)


func _on_FrameDurationSpinBox_value_changed(value):
	emit_signal("frame_length_changed", value)

func update_frame_start_value(value, max_value):
	frameStartSpinbox.value = value
	frameStartSpinbox.max_value = max_value
	
func update_frame_length_value(value, max_value):
	frameLengthSpinbox.value = value
	frameLengthSpinbox.max_value = max_value

func set_framedata_name(fd_name):
	framedataName.text = fd_name


func _on_FrameDataName_text_changed(new_text):
	emit_signal("framedata_name_changed", new_text)
