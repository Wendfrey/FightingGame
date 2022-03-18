extends Spatial

const STRING_TO_FIXED_POWER_TABLE = [
	1, 10, 100, 1000, 10000, 100000
]

export(int) var speed = SGFixed.ONE
export(PoolStringArray) var inital_position: PoolStringArray
export var initial_state = "STANDING_STATE"
export(GlobalConstants.DIRECTION) var forward

onready var kinematicBody = $FixedPlayerCollision
onready var state_list = $StateList

var current_state: EmptyState

var commands: Array = [load("res://Commands/DashCommand.gd").new()]

func _ready():
	kinematicBody.fixed_position = get_initial_pos()
	position_changed()

	current_state = state_list.get_node(initial_state)
	if not current_state:
		push_error(initial_state + " not found")

func _oneize_value(value: float) -> int:
	if(value > 0):
		return 1
	elif (value < 0):
		return -1
	return 0

func _save_state():
	var _state = {
		"position_x": kinematicBody.fixed_position_x,
		"position_y": kinematicBody.fixed_position_y,
	}
	for value in commands:
		var cmd = value as BaseCommand
		_state[cmd.get_key()] = cmd._save_state()
	
	_state["state_name"] = current_state.get_name()
	_state["state_data"] = current_state._save_state()
	
	return _state

func _load_state(state: Dictionary):
	set_position(state.get("position_x", 0), state.get("position_y", 0))
	for value in commands:
		var cmd = value as BaseCommand
		cmd._load_state(state.get(cmd.get_key()))
		
	current_state = state_list.get_node(state.get("state_name"))
	current_state._load_state(state.get("state_data", {}))
	position_changed()

func _get_local_input():
	var x_input:int = _oneize_value(Input.get_axis("player_1_left", "player_1_right"))
	var y_input:int = _oneize_value(Input.get_axis("player_1_down", "player_1_up"))
	var _input = {}
	_input[GlobalConstants.X_PLAYER_INPUT] = x_input
	_input[GlobalConstants.Y_PLAYER_INPUT] = y_input
	return _input
	
func _predict_remote_input(previous_input_for_node: Dictionary, ticks_since_real_input: int):
	return previous_input_for_node.duplicate()
	
func _network_preprocess(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_preprocess(input)
	current_state._on_player_preprocess(input)
	
func _network_process(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_process(input)
	current_state._on_player_process(input)
	
func _network_postprocess(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_postprocess(input)
	current_state._on_player_postprocess(input)
	
func position_changed():
	var new_pos = Vector3()
	new_pos.x = SGFixed.to_float(kinematicBody.fixed_position_x)
	new_pos.y = SGFixed.to_float(kinematicBody.fixed_position_y)
	global_transform.origin = new_pos

func get_initial_pos() -> SGFixedVector2:
	assert(inital_position.size() == 2, str(get_path()) + "Initial position must be of 2")
	var vector2D:SGFixedVector2 = SGFixedVector2.new()
#	Calculate X Position
	vector2D.x = _convert_decimal_text_to_fixed(inital_position[0])
#	Calculate Y Position
	vector2D.y = _convert_decimal_text_to_fixed(inital_position[1])
	return vector2D
	
func _convert_decimal_text_to_fixed(decimal_text: String) -> int:
	assert(decimal_text.is_valid_float(), "decimal_text must be valid float")
	var numbers:PoolStringArray = decimal_text.split(".")
	var units:int = SGFixed.from_int(int(numbers[0]))
	var decimal:int = 0
	if numbers.size() == 2 and numbers[1].length() > 0:
		if(numbers[1].length() > 5):
			numbers[1] = numbers[1].substr(0, 5)
		decimal = SGFixed.from_int(int(numbers[1])) / STRING_TO_FIXED_POWER_TABLE[clamp(numbers[1].length(), 0, 5)]

	return units + decimal

func set_position(fixed_x: int, fixed_y: int):
	kinematicBody.fixed_position_x = fixed_x
	kinematicBody.fixed_position_y = fixed_y
	kinematicBody.sync_to_physics_engine()
	position_changed()
	
func move_speed_body(_speed_fixed_x: int, _speed_fixed_y: int):
	kinematicBody.fixed_position_x += _speed_fixed_x
	kinematicBody.fixed_position_y += _speed_fixed_y
	kinematicBody.sync_to_physics_engine()
	position_changed()

func int_pow(_base: int, _power: int) -> int:
	var result:int  = 1
	for i in range(_power):
		result *= _base
	return result 
	
func state_change(new_state: String, _last_input: Dictionary, call_first_time: bool = true):
	current_state = state_list.get_node(new_state)
	if call_first_time:
		current_state._first_time_loaded(_last_input)

func _get_command_result(command_key: String, default:bool = false) -> bool:
	for object in commands:
		var cmd = object as BaseCommand
		if cmd.get_key() == command_key:
			return cmd._is_input_command_valid()
	return default
