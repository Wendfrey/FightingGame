extends BaseCommand

const TIME_LIMIT: int = 30
var zero_check: bool = false
var timer: int = 0
var x_input_memory: int = 0
var result: bool = false

func _load_state(_state: Dictionary):
	zero_check = _state.get("zero_check", false)
	timer = _state.get("timer", 0)
	x_input_memory = _state.get("x_input_memory", 0)
	result = _state.get("result", false)

func _save_state() -> Dictionary:
	return {
		"zero_check": zero_check,
		"timer": timer,
		"x_input_memory": x_input_memory,
		"result": result
	}
	
func _player_process(_input: Dictionary):
	pass

func _player_preprocess(_input:Dictionary):
	result = false
	var x_dir = _input.get(GlobalConstants.X_PLAYER_INPUT, 0)
	var y_dir = _input.get(GlobalConstants.Y_PLAYER_INPUT, 0)
	
	if y_dir != 0 or (x_dir == 0 and x_input_memory == 0):
		timer = 0
		zero_check = false
		x_input_memory = 0
		return false

	if (timer > 0):
		timer -= 1
		if timer == 0:
			zero_check = false
			x_input_memory = 0
	
	if x_input_memory == 0 or (x_input_memory != x_dir and x_dir != 0):
		x_input_memory = x_dir
		timer = TIME_LIMIT
		zero_check = false
	elif x_dir == 0:
		zero_check = true
	elif x_dir == x_input_memory:
		if zero_check: #DASH SUCCESS
			result = true
			zero_check = false
			x_input_memory = 0
			timer = 0
		else:
			timer = TIME_LIMIT

func _player_postprocess(_input:Dictionary):
	pass
	
func _is_input_command_valid() -> bool:
	return result
	
func get_key() -> String:
	return "DASH_COMMAND"
