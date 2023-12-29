# Control to add framedata to moves
# If you want to add your own custom frame data editor override the method
# _get_frame_editor_by_framedata_type and add your cus
extends Control
tool

onready var cell_editor = $MainFrame/vBox/Body/Canvas
onready var HScroller = $MainFrame/vBox/Body/HScrollBar
onready var VScroller = $MainFrame/vBox/Body/VScrollBar
onready var fdEditorContainer = $MainFrame/vBox/FrameDataEditorContainer
onready var propertyListBox = $MainFrame/vBox/PropertiesContainer/PropertiesListContainer/PropertiesList
onready var popupNewItem = $CreateNewFDItem
onready var popupModifyItem = $ModifyFDItem
onready var popupAddProperty = $AddPropertyDialog

var fdEditor: FrameEditorBase
var frame_data_selected:FrameDataItem
var frameDataItems: Array = []
var properties:Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	_update_hscroller()
	_update_vscroller()

# Called when move frame length has changed
func _update_hscroller():
	if (cell_editor.max_columns < cell_editor.columns):
		HScroller.visible = true
		HScroller.max_value = cell_editor.columns - cell_editor.max_columns
	else:
		HScroller.visible = false
		HScroller.value = 0

# Called when move frame length has changed
func _update_vscroller():
	if (cell_editor.max_rows < cell_editor.rows):
		VScroller.visible = true
		VScroller.max_value = cell_editor.rows - cell_editor.max_rows
	else:
		VScroller.visible = false
		VScroller.value = 0

# Called when move frame length has changed or column offset changed
func _update_frame_spinboxes():
	if(frame_data_selected and fdEditor):
		fdEditor.update_frame_start_value(
			frame_data_selected.frame_position, 
			cell_editor.columns - frame_data_selected.frame_length
		)

		fdEditor.update_frame_length_value(
			frame_data_selected.frame_length, 
			cell_editor.columns - frame_data_selected.frame_position
		)

# Called when cell has been selected
# To add or change a custom frame editor override this method
# When overriding do not forget to call super or else default editors will not show up
func _get_frame_editor_by_framedata_type(frame_data:FrameDataItem) -> FrameEditorBase:
	if(frame_data is HitboxFrameDataItem):
		return preload("res://addons/fight_data_creator/scenes/frameeditors/HitboxFrameDataEditor.tscn").instance() as FrameEditorBase
	return null

# Simple setup for a cellEditor, only called when obtained a editor for a cell
# It is safe to call frame_data_selected here
func _setup_fdEditor(_fdEditor:FrameEditorBase):
	#	Disconnect old fdEditor
	if(fdEditor):
		fdEditor.disconnect("frame_start_changed", self, "_on_framestart_changed")
		fdEditor.disconnect("frame_length_changed", self, "_on_framelength_changed")
		fdEditor.disconnect("framedata_name_changed", self, "_on_framedata_name_changed")
		fdEditor.disconnect("other_values_changed", self, "_on_framedata_other_values_changed")
		fdEditor.disconnect("property_add", self, "_on_framedata_property_add")
		fdEditor.disconnect("property_remove", self, "_on_framedata_property_remove")
		fdEditor.queue_free()


	fdEditor = _fdEditor
	if not fdEditor:
		return

	fdEditor.connect("frame_start_changed", self, "_on_framestart_changed")
	fdEditor.connect("frame_length_changed", self, "_on_framelength_changed")
	fdEditor.connect("framedata_name_changed", self, "_on_framedata_name_changed")
	fdEditor.connect("other_values_changed", self, "_on_framedata_other_values_changed")
	fdEditor.connect("property_add", self, "_on_framedata_property_add")
	fdEditor.connect("property_remove", self, "_on_framedata_property_remove")
	
	fdEditorContainer.add_child(fdEditor)
	
	fdEditor.set_framedata_name(frame_data_selected.name)

# Remove all framedata items when exiting, we do not want memory leaks
func _exit_tree():
	for fData in frameDataItems:
		if is_instance_valid(fData):
			fData.free()

## GETTERS ##
func get_frame_data(index:int):
	return frameDataItems[index]

func get_frame_data_array_size():
	return frameDataItems.size()

func get_frame_data_array():
	return frameDataItems

## SIGNAL RECEIVERS ##
# Edit Frame Base Signals
func _on_framestart_changed(value):
	frame_data_selected
	if(frame_data_selected):
		frame_data_selected.frame_position = int(value)
		_update_frame_spinboxes()
		cell_editor.update()

func _on_framelength_changed(value):
	if(frame_data_selected):
		frame_data_selected.frame_length = int(value)
		_update_frame_spinboxes()
		cell_editor.update()

func _on_framedata_name_changed(new_name):
	if(frame_data_selected):
		frame_data_selected.name = new_name
		cell_editor.update()

func _on_framedata_other_values_changed(_property_name, _value):
	if(frame_data_selected and not frame_data_selected._set(_property_name, _value)):
		push_warning("Could not store property {prop}".format({"prop":_property_name}))
	elif not frame_data_selected:
		push_warning("Could not store property due to no frame data object selected")

func _on_framedata_property_add(code:int, value):
	if (frame_data_selected):
		frame_data_selected.add_property_interaction(code, value)

func _on_framedata_property_remove(code:int, identifier):
	if (frame_data_selected):
		frame_data_selected.remove_property_interaction(code, identifier)

# Other signals
func _on_TotalLengthSpinBox_value_changed(value):
	cell_editor.columns = value
	_update_hscroller()
	_update_frame_spinboxes()

func _on_HScrollBar_value_changed(value):
	cell_editor.x_offset = value

func _on_VScrollBar_value_changed(value):
	cell_editor.y_offset = value

func _on_Canvas_frame_data_selected(frame_data:FrameDataItem):
	frame_data_selected = frame_data
	if frame_data:
		_setup_fdEditor(_get_frame_editor_by_framedata_type(frame_data))
		if(fdEditor):
			_update_frame_spinboxes()
			fdEditorContainer.visible = true
		else:
			push_error("FRAME EDITOR FOR FRAME DATA TYPE NOT FOUND")
	else:
		fdEditorContainer.visible = false

func _on_CreateNewFDItem_id_pressed(id):
	if id == 0:
		var hbFDI = HitboxFrameDataItem.new(cell_clicked.x, 1)
		hbFDI.name = "Hitbox " + str(frameDataItems.size())
		frameDataItems.append(hbFDI)
		cell_editor.rows = frameDataItems.size() + 1
		_update_vscroller()
		cell_editor.update()

var cell_clicked = Vector2.ZERO
func _on_Canvas_open_popup_menu():
	var showNewItemPopup = true
	for index in range(frameDataItems.size()):
		var frame_data = frameDataItems[index]
		if(cell_editor.is_mouse_over_framedata(frame_data, index)):
			showNewItemPopup = false
			frame_data_selected = frame_data
			break
	cell_clicked = cell_editor.get_mouse_cell_pos()
	if(showNewItemPopup):
		popupNewItem.popup(Rect2(get_global_mouse_position(), popupNewItem.rect_size))
	else:
		popupModifyItem.popup(Rect2(get_global_mouse_position(), popupNewItem.rect_size))

func _on_ModifyFDItem_id_pressed(id):
	match(id):
		0:
			var pos = frameDataItems.find(frame_data_selected)
			if pos > -1:
				frameDataItems.remove(pos)
			frame_data_selected.free()
			_on_Canvas_frame_data_selected(null)#Reset
			cell_editor.rows = frameDataItems.size() + 1
			cell_editor.update() #Update cell visuals

#Properties signals
func _on_AddNewPropertyButton_button_up():
	popupAddProperty.new_property()
	popupAddProperty.popup_centered()

func _on_AddPropertyDialog_new_property(_pname, _type):
	if properties.has(_pname):
		var index:int = 1
		while properties.has(_pname + str(index)):
			index += 1
	
		_pname = _pname + str(index)
	
	properties[_pname] = _type
	propertyListBox.update_properties(properties)

func _on_property_remove(_prop):
	if (properties.has(_prop)):
		properties.erase(_prop)
		propertyListBox.update_properties(properties)
	else:
		push_warning("Tried to remove property inexistant")

func _on_modify_property(_prop):
	popupAddProperty.modify_property(_prop, properties[_prop])
	popupAddProperty.popup_centered()
	
func _on_AddPropertyDialog_modify_property(old_name, _name, _type):
	if (properties.has(old_name)):
		properties.erase(old_name)
		properties[_name] = _type
		propertyListBox.update_properties(properties)
	else:
		push_warning("Tried to modify property inexistant")
