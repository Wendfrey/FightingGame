extends Control
tool

signal frame_data_selected(frame_data)
signal open_popup_menu()

const patch_size = 6
const cellTexture = preload("res://addons/fight_data_creator/imgs/grey.png")

export(Vector2) var cell_size:Vector2 = Vector2.ONE*32 setget _on_cell_size_update
export(int) var columns:int = 10 setget _on_columns_update
export(int) var x_offset:float = 0 setget _on_columns_offset_update
export(int) var rows:int = 1 setget _on_rows_update
export(int) var y_offset:float = 0 setget _on_rows_offset_update
export(float) var title_cell_height: float = 32 setget _on_title_height_set

var font:Font = get_theme_default_font()

var max_columns:int = 10
var max_rows:int = 5

var mbl_pressed:bool = false
var click_trigger:bool = false
var click_trigger_timer:SceneTreeTimer

#Offsets
var x_offset_px = 0
var y_offset_px = 0

func _ready():
	font = _set_font()
	max_columns = rect_size.x/cell_size.x
	max_rows = rect_size.y/cell_size.y - 1

#	INPUT FUNCTIONS	#
func _gui_input(event):
	var drop = false
	if event is InputEventMouseButton:
		if(event.button_index == BUTTON_LEFT):
			if(mbl_pressed and not event.pressed):
				drop = true
			mbl_pressed = event.pressed
			if(mbl_pressed):
				click_trigger = true
				click_trigger_timer = get_tree().create_timer(0.2)
				click_trigger_timer.connect("timeout", self, "_is_click")
			elif click_trigger: #Clicked
				click_trigger_timer.disconnect("timeout", self, "_is_click")
				click_trigger = false
				var frame_data_selected: bool = false
				for index in owner.get_frame_data_array_size():
					var frameData = owner.get_frame_data(index)
					if(is_mouse_over_framedata(frameData, index)):
						emit_signal("frame_data_selected", frameData)
						frame_data_selected = true
						break
				if not frame_data_selected:
					emit_signal("frame_data_selected", null)
				
		elif event.button_index == BUTTON_RIGHT and not event.pressed:
			var local_mouse = get_local_mouse_position()
			if local_mouse.x > 0 and local_mouse.x < get_table_width_px():
				emit_signal("open_popup_menu")

func _is_click():
	click_trigger = false
	
#	DRAW FUNCTIONS	#
func _draw():
	_draw_background()
	#	DRAW CELL NUMBER
	var _max_c:int = get_table_width() + ceil(get_x_offset_fmod1())
	for column in range(_max_c):
		var target_column = column + get_min_column_visible()
		var text = str(int(target_column))
		var x_text_center = font.get_string_size(text).x/2
		var x_pos = column * cell_size.x + cell_size.x/2 - x_text_center - x_offset_px
		var c_pos:Vector2 = Vector2(x_pos, title_cell_height/2)
		if(c_pos.x < -2 or c_pos.x - 2 > get_table_width_px()):
			continue
		draw_string(font, c_pos, text)

	for _index_ in range(owner.get_frame_data_array_size()):
		var obj:FrameDataItem = owner.get_frame_data(_index_) 
		_draw_cell(obj.frame_position, obj.frame_length, _index_, obj._md_color, obj.name)

func _draw_background():
	var cell_color:Array = [Color(0.2,0.2,0.3), Color(0.3,0.3,0.4)] 
	for _column_ in range(get_table_width() + ceil(get_x_offset_fmod1())):
		for _row_ in range(min(rows, max_rows) + ceil(get_y_offset_fmod1())):
			_draw_cell(_column_ + get_min_column_visible(), 1,  _row_ + get_min_row_visible(), cell_color[int(_column_ + x_offset) % 2])

func _draw_cell(_frame:int, _width:int, _row:int, _color:Color, name:String = ""):
	var right_bound = _frame + _width - 1
	#	DO NOT DRAW IF IT'S OUTSIDE BOUNDS
	var total_max_columns = get_table_current_max_width() + ceil(get_x_offset_fmod1())
	if (_frame > total_max_columns):
		return
	if (right_bound < get_min_column_visible()):
		return
		
	var total_max_rows = get_table_current_max_height() + ceil(get_y_offset_fmod1())
	if(_row > total_max_rows):
		return
	if (_row < get_min_row_visible()):
		return
	var _valid_column = _frame - get_min_column_visible() - get_x_offset_fmod1()
	var _valid_row:float = float(_row - get_min_row_visible()) - get_y_offset_fmod1()
	
	_draw_cell_whole(_valid_column, _width, _valid_row, _color, name)

#Draw cell, 9 region drawing if possible 
func _draw_cell_whole(_column_start:float , _cell_width:int, _row:float, _color:Color, name:String = ""):
	var start_x = max(_column_start * cell_size.x, 0)
	var start_y = max(_row * cell_size.y, 0) + title_cell_height
	
	var worldregion:Rect2 = Rect2() 
	var textureregion:Rect2 = Rect2()
	
	# Init offset x
	var size_offset:Vector2 = Vector2.ZERO
	var total_offset:Vector2 = Vector2.ZERO
	var total_deducted:Vector2 = Vector2.ZERO
	var worldregion_desired_size:Vector2 = Vector2.ZERO
	if(_column_start < 0):
		total_offset.x = abs(_column_start) * cell_size.x
	if(_row < 0):
		total_offset.y = abs(_row) * cell_size.y
		
	size_offset.x = total_offset.x
	for _x_section in range(3):
		worldregion_desired_size.x = 0
		total_deducted.x = total_offset.x - size_offset.x
		match (_x_section):
			0:
				worldregion.position.x = start_x
				textureregion.position.x = 0
				
				worldregion_desired_size.x = patch_size
			1:
				worldregion.position.x = start_x + patch_size - total_deducted.x
				textureregion.position.x = patch_size
				
				worldregion_desired_size.x = _cell_width * cell_size.x - patch_size * 2
			2:
				worldregion.position.x = start_x + _cell_width * cell_size.x - patch_size - total_deducted.x
				textureregion.position.x = cellTexture.get_width() - patch_size
				worldregion_desired_size.x = patch_size
		
		#Calculate x sizes
		worldregion.size.x = max(worldregion_desired_size.x - size_offset.x, 0)
		textureregion.size.x = min(worldregion.size.x, patch_size)
		
		#How much offset left?
		if(size_offset.x > 0):
			size_offset.x -= worldregion_desired_size.x - worldregion.size.x
			if size_offset.x < 0:
				size_offset.x = 0

		#Do not print if there is no size
		if(worldregion.size.x <= 0):
			continue
		# If reached end of screen, we cant draw more textures, exit loop
		if(worldregion.position.x >= get_table_width_px()):
			break; 
		# If the size end of the draw is outside margins clamp it
		if(worldregion.position.x + worldregion.size.x >= get_table_width_px()):
			worldregion.size.x = get_table_width_px() - worldregion.position.x
		
		# Init y offset0
		size_offset.y = total_offset.y
		#Calculate Y of regions
		for _y_section in range(3):
			worldregion_desired_size.y = 0
			total_deducted.y = total_offset.y - size_offset.y
			
			match (_y_section):
				0:
					worldregion.position.y = start_y
					textureregion.position.y = 0
					
					worldregion_desired_size.y = patch_size
				1:
					worldregion.position.y = start_y + patch_size - total_deducted.y
					textureregion.position.y = patch_size
					
					worldregion_desired_size.y = cell_size.y - patch_size * 2
				2:
					worldregion.position.y = start_y + cell_size.y - patch_size - total_deducted.y
					textureregion.position.y = cellTexture.get_height() - patch_size
					worldregion_desired_size.y = patch_size
			
			#Calculate y sizes
			worldregion.size.y = max(worldregion_desired_size.y - size_offset.y, 0)
			textureregion.size.y = min(worldregion.size.y, patch_size)
			
			#How much offset left?
			if(size_offset.y > 0):
				size_offset.y -= worldregion_desired_size.y - worldregion.size.y
				if size_offset.y < 0:
					size_offset.y = 0

			#Do not print if there is no size
			if(worldregion.size.y <= 0):
				continue
			# If reached end of screen, we cant draw more textures, exit loop
			if(worldregion.position.y >= get_table_height_px()):
				break; 
			# If the size end of the draw is outside margins clamp it
			if(worldregion.position.y + worldregion.size.y >= get_table_height_px()):
				worldregion.size.y = get_table_height_px() - worldregion.position.y
				
			draw_texture_rect_region(cellTexture, worldregion, textureregion, _color)
	
	if(not name.empty()):
		var x_length = font.get_string_size(name).x
		var string_x_ini = max(_column_start * cell_size.x, 0) 
		var string_x_fin = min((_column_start + _cell_width) * cell_size.x, get_table_width_px())
		draw_string(
			font, 
			Vector2((string_x_fin+ string_x_ini) * 0.5 - x_length/2, cell_size.y * (_row + 0.5) + title_cell_height),
			name
		)

func is_mouse_over_framedata(framedata:FrameDataItem, index: int) -> bool:
	if(framedata.frame_position + framedata.frame_length - 1 < get_min_column_visible()):
		return false
	if(framedata.frame_position > max_columns + get_min_column_visible()):
		return false
	if(index < get_min_row_visible()):
		return false
	if(index > max_rows + get_min_row_visible()):
		return false

	# We know that this cell is being displayed, totally or partially
	var local_pos:Vector2 = Vector2(
		framedata.frame_position - get_min_column_visible() - get_x_offset_fmod1(),
		index - get_min_row_visible() - get_x_offset_fmod1()
	)
	var min_pos = Vector2(
		cell_size.x * max(local_pos.x, 0),
		cell_size.y * max(local_pos.y, 0) + title_cell_height
	)
	var max_pos = Vector2(
		cell_size.x * min(local_pos.x + framedata.frame_length, max_columns),
		cell_size.y * min(local_pos.y + 1, max_rows) + title_cell_height
	)
	var mouse_pos = get_local_mouse_position()
	if(mouse_pos.x < min_pos.x or mouse_pos.x >= max_pos.x):
		return false
	if(mouse_pos.y < min_pos.y or mouse_pos.y >= max_pos.y):
		return false
	
	return true

func _on_Canvas_resized():
	max_columns = rect_size.x/cell_size.x
	max_rows = rect_size.y/cell_size.y - 1

#GETTERS AND SETTERS
#	TABLE X/WIDTH GETTERS
func get_table_current_max_width() -> int:
	return int(min(columns, max_columns + get_min_column_visible())) - 1

func get_table_width() -> int:
	return int(min(columns, max_columns))

func get_table_width_px() -> float:
	return cell_size.x * float(get_table_width())

func get_min_column_visible()-> int:
	return int(x_offset)
	
func get_x_offset_fmod1() -> float:
	return fmod(x_offset, 1)
	
func get_x_offset_fmod1_px() -> float:
	return x_offset_px

#	TABLE Y/HEIGHT GETTERS
func get_table_current_max_height() -> int:
	return int(min(rows, max_rows + get_min_row_visible())) - 1

func get_table_height() -> int:
	return int(min(rows, max_rows))

func get_table_height_px() -> float:
	return cell_size.y * float(get_table_height()) + title_cell_height

func get_min_row_visible()-> int:
	return int(y_offset)
	
func get_y_offset_fmod1() -> float:
	return fmod(y_offset, 1)

func get_y_offset_fmod1_px() -> float:
	return y_offset_px
	
func get_mouse_cell_pos() -> Vector2:
	var result = Vector2.ZERO
	
	var mouse_pos = get_local_mouse_position()
	#Apply offset
	mouse_pos.x += get_x_offset_fmod1_px()
	mouse_pos.y += get_y_offset_fmod1_px()
	
	
	result.x = int(mouse_pos.x / cell_size.x)
	result.y = int(mouse_pos.y / cell_size.y)
	
	return result

func _on_cell_size_update(_cell_size):
	cell_size = _cell_size
	max_columns = rect_size.x/cell_size.x
	max_rows = rect_size.y/cell_size.y - 1
	update()
	
#	ROWS SETS
func _on_rows_update(_rows):
	rows = _rows
	update()
	
func _on_rows_offset_update(_rows):
	y_offset = _rows
	_recalculate_y_offset_pixels()
	update()

func _recalculate_y_offset_pixels():
	y_offset_px = fmod(y_offset, 1) * cell_size.y

#	COLUMN SETS
func _on_columns_update(_columns):
	columns = _columns
	update()
	
func _on_columns_offset_update(_x_offset):
	x_offset = _x_offset
	_recalculate_x_offset_pixels()
	update()

func _recalculate_x_offset_pixels():
	x_offset_px = fmod(x_offset, 1) * cell_size.x

#	Other sets
func _set_font() -> Font:
	var dinfont = DynamicFont.new()
	dinfont.font_data = preload("res://addons/fight_data_creator/fonts/RobotoMono-Medium.ttf")
	dinfont.size = 16
	return dinfont

func _on_title_height_set(_title_height):
	title_cell_height = _title_height
	update()
