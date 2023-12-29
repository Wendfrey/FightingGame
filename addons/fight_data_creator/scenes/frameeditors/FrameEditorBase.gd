extends Control
class_name FrameEditorBase
tool

signal frame_start_changed(value)
signal frame_length_changed(value)
signal framedata_name_changed(new_name)
signal other_values_changed(property_name, property_value)
signal property_add(inter_code, value)
signal property_remove(inter_code, value)


func update_frame_start_value(value, max_value):
	pass
	
func update_frame_length_value(value, max_value):
	pass

#Only called when selecting a frame data
func set_framedata_name(fd_name):
	pass
