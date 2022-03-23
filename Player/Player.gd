extends SGKinematicBody2D

const STRING_TO_FIXED_POWER_TABLE = [
	1, 10, 100, 1000, 10000, 100000
]

export(int) var speed = SGFixed.ONE
export var initial_state = "STANDING_STATE"
export(GlobalConstants.DIRECTION) var forward
export(PoolStringArray) var commands:Array = [] setget _init_cmds
export(String) var input_str = "player_1"

onready var state_list = $StateList
onready var hurtbox = $SGCollisionShape2D.shape as SGRectangleShape2D
onready var hurtbox_visual = $HurtBox

var current_state: EmptyState

var input_array:PoolByteArray

func _ready():
	input_array = PoolByteArray()

	current_state = state_list.get_node(initial_state)
	if not current_state:
		push_error(initial_state + " not found")
		
	if forward != GlobalConstants.DIRECTION.RIGHT:
		$PlayerSprite.scale.x = -1
		
	hurtbox_visual.rect_size = Vector2(SGFixed.to_float(hurtbox.extents.x), SGFixed.to_float(hurtbox.extents.y)) * 2
	hurtbox_visual.rect_position = -hurtbox_visual.rect_size*.5
	hurtbox_visual.change_color_by_state(current_state.name)

func _oneize_value(value: float) -> int:
	if(value > 0):
		return 1
	elif (value < 0):
		return -1
	return 0

func _save_state():
	var _state = {
		"position_x": fixed_position.x,
		"position_y": fixed_position.y,
		"input_array": input_array,
	}
	for value in commands:
		var cmd = value as BaseCommand
		_state[cmd.get_key()] = cmd._save_state()
	
	_state["state_name"] = current_state.get_name()
	_state["state_data"] = current_state._save_state()
	
	return _state

func _load_state(state: Dictionary):
	set_player_position(state.get("position_x", 0), state.get("position_y", 0))
	
	input_array = state.get("input_array", PoolByteArray())
	for value in commands:
		var cmd = value as BaseCommand
		cmd._load_state(state.get(cmd.get_key()))
		
	current_state = state_list.get_node(state.get("state_name"))
	current_state._load_state(state.get("state_data", {}))
	hurtbox_visual.change_color_by_state(current_state.name)


func _get_local_input():
	var x_input:int = _oneize_value(Input.get_axis(input_str + "_left", input_str + "_right"))
	var y_input:int = _oneize_value(Input.get_axis(input_str + "_down", input_str +  "_up"))
	var attack: bool = Input.is_action_just_pressed(input_str + "_attack")
	var _input = {}
	_input[GlobalConstants.X_PLAYER_INPUT] = x_input
	_input[GlobalConstants.Y_PLAYER_INPUT] = y_input
	_input[GlobalConstants.ATTACK_PLAYER_INPUT] = attack
	return _input
	
func _predict_remote_input(previous_input_for_node: Dictionary, ticks_since_real_input: int):
	var output = previous_input_for_node.duplicate()
	if output.has(GlobalConstants.ATTACK_PLAYER_INPUT):
		output.erase(GlobalConstants.ATTACK_PLAYER_INPUT)
	return output
	
func _network_preprocess(input: Dictionary):
	_add_input_to_array(input)
		
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_preprocess(input_array, forward)
	current_state._on_player_preprocess(input)
	
func _network_process(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_process(input_array, forward)
	current_state._on_player_process(input)
	
func _network_postprocess(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_postprocess(input_array, forward)
	current_state._on_player_postprocess(input)
	
func set_player_position(_pos_x, _pos_y):
	fixed_position.x = _pos_x
	fixed_position.y = _pos_y
	sync_to_physics_engine()
	
func move_speed_body(_speed_fixed_x: int, _speed_fixed_y: int):
	var speed = SGFixedVector2.new()
	speed.x = _speed_fixed_x
	speed.y = _speed_fixed_y
	fixed_position.x += _speed_fixed_x
	fixed_position.y += _speed_fixed_y
	sync_to_physics_engine()
	
func state_change(new_state: String, _last_input: Dictionary, call_first_time: bool = true):
	hurtbox_visual.change_color_by_state(new_state)
	current_state = state_list.get_node(new_state)
	if call_first_time:
		current_state._first_time_loaded(_last_input)

func _get_command_result(command_key: String, default:bool = false) -> bool:
	for object in commands:
		var cmd = object as BaseCommand
		if cmd.get_key() == command_key:
			return cmd._is_input_command_valid()
	return default
	
func _add_input_to_array(_input: Dictionary):
	var processed_input = 0
	var _x = _input.get(GlobalConstants.X_PLAYER_INPUT, 0)
	if(_x == 1):
		processed_input |= 0b0000_0001
	elif _x == -1:
		processed_input |= 0b0000_0010
	var _y = _input.get(GlobalConstants.Y_PLAYER_INPUT, 0)
	if(_y == 1):
		processed_input |= 0b0000_0100
	elif _y == -1:
		processed_input |= 0b0000_1000
	
	if(_input.get(GlobalConstants.ATTACK_PLAYER_INPUT, false)):
		processed_input |= 0b0001_0000
	
	input_array.insert(0, processed_input)
	
	if(input_array.size() > 20):
		input_array.resize(20)

func _init_cmds(values):
	if commands.size() > 0:
		commands.clear()
	for index in range(values.size()):
		
		commands.append(load(values[index]).new())

func _on_hitbox_collision(attack_data: AttackData):
	current_state._on_hit(attack_data)
	
