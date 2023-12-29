extends Node

const X_PLAYER_INPUT = "x_player"
const Y_PLAYER_INPUT = "y_player"
const ATTACK_PLAYER_INPUT = "attack_player"

enum DIRECTION {
	LEFT = 1, RIGHT = 0
}

const BLOCKING_DIR = {
	0: [1,4,7],
	1: [3,6,9]
}

const MAX_RESULT_BUFFER: int = 3

enum HIT_LEVEL {
	LOW = 0, MID = 1, HIGH = 2
}

const PIXEL_TO_WORLD = 0.01
const WORLD_TO_PIXEL = 100

static func fromStringToFixedVal(_str:String) -> int:
	var result:int = 0
	if(_str.is_valid_integer()):
		result = _str.to_int() << 16
	elif(_str.is_valid_float()):
		var splitted = _str.split(".", false, 2)
		result = splitted[1].to_int() << 16
		for i in splitted[1].length():
			result /= 10
		result += splitted[0] * 65536
	return result
