extends BaseCommand

const MOTION = {
	0: [6, 5, 6], #Right facing -> · ->
	1: [4, 5, 4]  #Left facing
}
#Leniency doesn't make sense for first input
const LENIENT = {
	0: [[],[],[]],
	1: [[],[],[]]
}
const max_ticks = 7

var result_buffer: int = 0
var motion_array:Array = []
var tick:int = 0

func _load_state(_input: Dictionary):
	result_buffer = _input.get("result_buffer", 0)
	motion_array = _input.get("motion_array", [])
	tick = _input.get("tick", 0)
	
func _save_state() -> Dictionary:
	return {
		"result_buffer": result_buffer,
		"motion_array": motion_array.duplicate(true),
		"tick": tick
	}

func _player_preprocess(_bit_input: int, facing: int):
	
#	If the buffer is still active do not check
	if result_buffer > 0:
		result_buffer -= 1

	var _motion: int
	
	_motion = 5
	if _bit_input & 0b0001:
		_motion += 1
	if _bit_input & 0b0010:
		_motion -= 1
	if _bit_input & 0b0100:
		_motion += 3
	if _bit_input & 0b1000:
		_motion -= 3

	if motion_array.empty() or motion_array[-1]["motion"] != _motion:
		if not motion_array.empty():
			motion_array[-1]["last_tick"] = tick
		motion_array.append({"motion": _motion})
	
	if (motion_array.size() > 1):
		tick += 1
		
	find_valid_first_step(facing)

func find_valid_first_step(facing:int):
	for index in range(motion_array.size()):
		if motion_array[0]["motion"] != MOTION[facing][0] or tick > max_ticks:
			var erased_motion = motion_array[0]
			motion_array.remove(0)
			reload_last_ticks()
			continue
		#If motions are valid then we do not need to keep checking
		match (_valid_motion(facing)):
			0:
				break
			2:
				result_buffer = GlobalConstants.MAX_RESULT_BUFFER
				motion_array.remove(0)
				reload_last_ticks()
				break
# returns if the motion is valid:
#	0 -> not valid, 1 -> valid but incomplete, 2 -> valid and complete
func _valid_motion(facing:int) -> int:
	var step: int = 0
	
	for motion_dict in motion_array:
		var _motion = motion_dict["motion"]
		if MOTION[facing][step] == _motion:
			step += 1
			if MOTION[facing].size() <= step:
				# COMPLETED INPUT
				return 2
		elif not LENIENT[facing][step].has(_motion):
			return 0
	# if we ended motion array but we found valid inputs then it still valid 
	# but not completed input
	return 1

func reload_last_ticks():
	if motion_array.size() <= 1:
		tick = 0
	else:
		var new_tick = motion_array[0]["last_tick"]
		tick -= new_tick
		for index in range(motion_array.size() - 1):
			motion_array[index]["last_tick"] = motion_array[index]["last_tick"] - new_tick

func _is_input_command_valid() -> bool:
	return result_buffer > 0
	
func get_key() -> String:
	return "ForwardDashCommand"
