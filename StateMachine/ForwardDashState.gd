extends "res://StateMachine/NonBlockingState.gd"

const TICKS_MAX:int = 30
const TICKS_MOVEMENT:int = 20
export(int) var FORWARD_SPEED:int  = 65536 #Max distance  1px/tick

var current_tick:int  = 0
func _load_state(_input:Dictionary):
	current_tick = _input.get("current_tick", 0)
	
func _save_state() -> Dictionary:
	return {
		"current_tick": current_tick,
	}

func _first_time_loaded(_input: Dictionary):
	._first_time_loaded(_input)
	current_tick = 0
	_on_player_preprocess(_input)

func _on_player_preprocess(_input: Dictionary):
	if current_tick == TICKS_MAX:
		owner.state_change("STANDING_STATE", _input)
		return
	elif current_tick < TICKS_MAX:
		current_tick += 1
		
	if current_tick <=  TICKS_MOVEMENT:
		var speed
		if owner.forward == GlobalConstants.DIRECTION.RIGHT:
				speed = FORWARD_SPEED
		else:
				speed = -FORWARD_SPEED
		
		owner.move_speed_body(speed, 0)
