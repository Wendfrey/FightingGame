extends "res://stateMachine/NonBlockingState.gd"

const TICKS_MAX:int = 35
const TICKS_MOVEMENT:int = 20
export(int) var BACK_SPEED:int  = 65536 #Max distance 262140 -> 3,9999 ~ 4

var current_tick:int  = 0
func _load_state(_input:Dictionary):
	current_tick = _input.get("current_tick", 0)
	
func _save_state() -> Dictionary:
	return {
		"current_tick": current_tick,
	}

func _first_time_loaded(_params: Dictionary):
	._first_time_loaded(_params)
	current_tick = 0
	_on_player_preprocess(_params)

func _on_player_preprocess(_params: Dictionary):
	._on_player_preprocess(_params)
	if current_tick == TICKS_MAX:
		stateMachine.state_change("STANDING_STATE", _params)
		return
	elif current_tick < TICKS_MAX:
		current_tick += 1
		
	if current_tick <=  TICKS_MOVEMENT:
		var speed
		if stateMachine.forward == GlobalConstants.DIRECTION.RIGHT:
				speed = -BACK_SPEED
		else:
				speed = BACK_SPEED
		
		stateMachine.move_speed_body(speed, 0)
