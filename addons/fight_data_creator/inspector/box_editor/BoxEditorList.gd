extends WindowDialog
tool

signal new_box
signal edit_box(index)

const BoxItemScene = preload("res://addons/fight_data_creator/inspector/box_editor/BoxEditorItem.tscn") 

var data:Array = Array()

onready var boxItemContainer = $ScrollContainer/VBoxContainer/BoxItemsContainer

func _ready():
	_refresh()

func refresh(_data:Array):
	data.clear()
	data.append_array(_data)
	_refresh()

func _on_BoxEditorList_about_to_show():
	_refresh()

func _on_edit_box_data(index):
	emit_signal("edit_box", index)

func _on_AddBoxDataButton_button_up():
	emit_signal("new_box")

func _refresh():
	if (boxItemContainer == null):
		return
	var diff:int = data.size() - boxItemContainer.get_child_count()
	if diff > 0:
		for index in range(diff):
			var new_child = BoxItemScene.instance()
			new_child.connect("edit_box_data", self, '_on_edit_box_data')
			boxItemContainer.add_child(new_child)
	elif diff < 0:
		for index in range(diff):
			var old_child = boxItemContainer.get_children()[-1]
			boxItemContainer.remove_child(old_child)
			old_child.queue_free()
			
	for index in range(data.size()):
		var boxData:PlayerResource.Box = data[index]
		var boxUiItem = boxItemContainer.get_child(index)
		boxUiItem.set_data(boxData)
