extends VBoxContainer
tool

const PropertyItemScene = preload("res://addons/fight_data_creator/scenes/PropertyItemBox.tscn")

func update_properties(properties_dict:Dictionary):
	var diff = properties_dict.size() - get_child_count()
	if(diff > 0):
		for i in range(diff):
			var child = PropertyItemScene.instance()
			child.connect("remove_property", owner, "_on_property_remove")
			child.connect("edit_property", owner, "_on_modify_property")
			add_child(child)
	elif diff < 0:
		for i in range( abs(diff)):
			var child = get_child(get_child_count()-1)
			remove_child(child)
			child.queue_free()
	
	for i in range(properties_dict.size()):
		get_child(i).text = properties_dict.keys()[i]
		get_child(i).type = properties_dict[properties_dict.keys()[i]]
		
