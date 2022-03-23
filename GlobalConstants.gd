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
