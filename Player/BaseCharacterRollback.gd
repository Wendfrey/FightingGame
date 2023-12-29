extends SGKinematicBody2D

const STRING_TO_FIXED_POWER_TABLE = [
	1, 10, 100, 1000, 10000, 100000
]

const MotionCommandClass = preload("res://commands/MotionCommand.gd")
const FDashCommandClass = preload("res://commands/ForwardDashCommand.gd")
const BDashCommandClass = preload("res://commands/BackDashCommand.gd")

enum PlAYER {
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

export(int) var speed = SGFixed.ONE
export var initial_state = "STANDING_STATE"
export(GlobalConstants.DIRECTION) var forward
var commands:Array = []
export(PlAYER) var player_type = PlAYER.PLAYER_1
export(String) var framedata_path

onready var hurtbox = $HurtboxArea/HurtboxShape.shape as SGRectangleShape2D
onready var hurtbox_visual = $HurtBoxVisual
onready var framedata = FrameDataUtilities.parseFrameData(framedata_path)
onready var hurtboxArea = $HurtboxArea
var input_str

func _ready():
	$HurtboxArea.collision_mask = player_type
	input_str = "player_" + str(player_type)
		
	if forward != GlobalConstants.DIRECTION.RIGHT:
		$PlayerSprite.scale.x = -1
		
	commands.append(FDashCommandClass.new())
	commands.append(BDashCommandClass.new())
	for motion_name in framedata["motions"]:
		commands.append(MotionCommandClass.new(motion_name, framedata["motions"][motion_name]))
		
	hurtbox_visual.rect_size = Vector2(SGFixed.to_float(hurtbox.extents.x), SGFixed.to_float(hurtbox.extents.y)) * 2
	hurtbox_visual.rect_position = -hurtbox_visual.rect_size*.5
#	hurtbox_visual.change_color_by_state(current_state.name)
	
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
	}
	for value in commands:
		var cmd = value as BaseCommand
		_state[cmd.get_key()] = cmd._save_state()
	
	
	return _state

func _load_state(state: Dictionary):
	set_player_position(state.get("position_x", 0), state.get("position_y", 0))
	
	for value in commands:
		var cmd = value as BaseCommand
		cmd._load_state(state.get(cmd.get_key()))

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
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_preprocess(_get_input_processed(input), forward)

	
func _network_process(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_process(_get_input_processed(input), forward)
	
func _network_postprocess(input: Dictionary):
	for object in commands:
		var cmd = object as BaseCommand
		cmd._player_postprocess(_get_input_processed(input), forward)
	
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

func _get_command_result(command_key: String, default:bool = false) -> bool:
	for object in commands:
		var cmd = object as BaseCommand
		if cmd.get_key() == command_key:
			return cmd._is_input_command_valid()
	return default
	
func _get_input_processed(_input: Dictionary):
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
	
	return processed_input

func lerp_new_pos(_origin: SGFixedVector2, _distance: SGFixedVector2, _count:int, _max:int):
	fixed_position.x = _origin.x + _distance.x * _count /_max
	fixed_position.y = _origin.y + _distance.y * _count /_max
	sync_to_physics_engine()
	
func get_enemy_player_type() -> int:
	return PlAYER.PLAYER_2 if player_type == PlAYER.PLAYER_1 else PlAYER.PLAYER_1

#Little cheat
func sync_to_physics_engine():
	.sync_to_physics_engine()
	hurtboxArea.sync_to_physics_engine()
