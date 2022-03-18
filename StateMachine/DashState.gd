extends "res://StateMachine/NonBlockingState.gd"

const TICKS_MAX:int = 30
const TICKS_MOVEMENT:int = 20
const FORWARD_SPEED:int  = 13107 #Max distance 262140 -> 3,9999 ~ 4
const BACK_SPEED = 10649 #Max distance 212980 -> 3,2498

var current_tick:int  = 0
var direction: int = 0

func _load_state(_input:Dictionary):
	current_tick = _input.get("current_tick", 0)
	direction = _input.get("direction", 0)
	
func _save_state() -> Dictionary:
	return {
		"current_tick": current_tick,
		"direction": direction
	}

func _first_time_loaded(_input: Dictionary):
	current_tick = 0
	direction = _input.get(GlobalConstants.X_PLAYER_INPUT)
	_on_player_preprocess(_input)

func _on_player_preprocess(_input: Dictionary):
	if current_tick == TICKS_MAX:
		get_owner().state_change("STANDING_STATE", _input)
		return		
	elif current_tick < TICKS_MAX:
		current_tick += 1
		
	if current_tick <=  TICKS_MOVEMENT:
		var speed = direction
		if get_owner().forward == GlobalConstants.DIRECTION.LEFT:
			if direction == -1 :
				speed *= FORWARD_SPEED
			else:
				speed *= BACK_SPEED
		else:
			if direction == 1 :
				speed *= FORWARD_SPEED
			else:
				speed *= BACK_SPEED
		
		get_owner().move_speed_body(speed, 0)
