extends EditorProperty

const BoxSceneListEditor = preload("res://addons/fight_data_creator/inspector/box_editor/BoxEditorList.tscn")
const BoxEditorDialog = preload("res://addons/fight_data_creator/inspector/box_editor/BoxEditorDialog.tscn")

var box_editor_list = BoxSceneListEditor.instance()
var box_editor_item = BoxEditorDialog.instance()

var current_value:Array = Array()
var _updating = false

func _init():
	var button = Button.new()
	button.text = 'Edit Boxes'
	add_child(button)
	add_child(box_editor_list)
	add_child(box_editor_item)
	
	add_focusable(box_editor_list)
	
	# Reset box edit list data
	refresh_controls()
	
	#Edit Boxes connection
	button.connect("button_up", self,'_on_EditButton_click')
	
	#List of boxes connection
	box_editor_list.connect('new_box', self, '_on_new_box')
	box_editor_list.connect('edit_box', self, '_on_edit_box')
	
	#Item box connection
	box_editor_item.connect("box_data_changed", self, '_on_itembox_data_changed')

func update_property():
	box_editor_list.window_title = get_edited_property()
	var new_value = get_edited_object()[get_edited_property()]
	
	if (new_value == current_value):
		return
	
	_updating = true
	current_value = new_value
	refresh_controls()
	_updating = false

func refresh_controls():
	box_editor_list.refresh(current_value)

func _on_itembox_data_changed(box):
	if not current_value.has(box):
		current_value.append(box)
	print(current_value)
	emit_changed(get_edited_property(), current_value)
	refresh_controls()
	
func _on_new_box():
	var boxdata = PlayerResource.Box.new()
	
	box_editor_item.boxData = boxdata
	box_editor_item.popup_centered()
	
func _on_edit_box(index):
	box_editor_item.boxData = current_value[index]
	box_editor_item.popup_centered()

func _on_EditButton_click():
	if (_updating):
		return
	box_editor_list.popup_centered()
