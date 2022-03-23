extends "res://Commands/BaseCommand.gd"

const MOTION = {
	0: [6, 5, 6], #Right facing -> · ->
	1: [4, 5, 4]  #Left facing
}
#Leniency doesn't make sense for first input
const LENIENT = {
	0: [[],[],[]],
	1: [[],[],[]]
}

var result_buffer: int = 0

func _load_state(_input: Dictionary):
	result_buffer = _input.get("result_buffer", 0)
	
func _save_state() -> Dictionary:
	return {
		"result_buffer": result_buffer
	}

func _player_preprocess(_input: PoolByteArray, facing: int):
	
#	If the buffer is still active do not check
	if result_buffer > 0:
		result_buffer -= 1
		if result_buffer > 0:
			return

	var _motion: int
	var motion_index: int = 0
	var desired_motion:Array = MOTION[facing].duplicate()
	var len_motion_list:Array = LENIENT[facing].duplicate()
	
	desired_motion.invert()
	len_motion_list.invert()
	
	for data in _input:
		_motion = 5
		if data & 0b0001:
			_motion += 1
		if data & 0b0010:
			_motion -= 1
		if data & 0b0100:
			_motion += 3
		if data & 0b1000:
			_motion -= 3
		
		if _motion == desired_motion[motion_index]:
			motion_index += 1
			if motion_index == desired_motion.size():
				result_buffer = GlobalConstants.MAX_RESULT_BUFFER
				return
		else:
			var is_lenient: bool = false
			if motion_index > 0 and _motion == desired_motion[motion_index-1]:
				continue
			var lenient_data:Array = len_motion_list[motion_index]
			for len_motion in lenient_data:
				if len_motion == _motion:
					is_lenient = true
					break
			if not is_lenient:
				return
	
		

func _is_input_command_valid() -> bool:
	return result_buffer > 0
	
func get_key() -> String:
	return "ForwardDashCommand"
