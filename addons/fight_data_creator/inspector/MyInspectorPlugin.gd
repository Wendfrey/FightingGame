extends EditorInspectorPlugin

const PlayerResource = preload("res://addons/fight_data_creator/PlayerResource.gd")
const BoxEditorProperty = preload("res://addons/fight_data_creator/inspector/BoxesEditorProperty.gd")

func can_handle(object):
	return object is PlayerResource

func parse_property(object, type, path, hint, hint_text, usage):
	print("object %s" % object + " type %s" % type + " path %s" % path +
	 " hint %s" % hint + " hint_text %s" % hint_text + " usage %s" % usage)
	
	if(path == 'hitboxes' or path == 'hurtboxes'):
		add_property_editor(path, BoxEditorProperty.new())
		return true
	return false
