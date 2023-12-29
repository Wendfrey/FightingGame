extends "res://stateMachine/NonBlockingState.gd"

var on_hit_knockback:int
var ticks_counter: int
var max_ticks:int
var direction: int

func _first_time_loaded(_params: Dictionary):
	var oh_data = _params["oh_data"]
	on_hit_knockback = oh_data.get("knockback", PoolIntArray())
	ticks_counter = 0
	max_ticks = oh_data.get("hitstun", 0)
	direction = -1 if stateMachine.forward == GlobalConstants.DIRECTION.RIGHT else 1
	
	# Do a tick
	_on_player_preprocess(_params)

func _load_state(_state: Dictionary):
	on_hit_knockback = _state['on_hit_knockback']
	ticks_counter = _state['ticks_counter']
	max_ticks = _state['max_ticks']
	direction = _state['direction']
	
func _save_state() -> Dictionary:
	return {
		'on_hit_knockback': on_hit_knockback,
		'ticks_counter': ticks_counter,
		'max_ticks': max_ticks,
		'direction': direction
	}

func _on_player_preprocess(_params: Dictionary):
	._on_player_preprocess(_params)
	if (ticks_counter == max_ticks):
		stateMachine.state_change('STANDING_STATE', _params)
		return
		
	if(on_hit_knockback != 0):
		stateMachine.move_speed_body(on_hit_knockback * direction, 0)
	
	ticks_counter += 1
	._on_player_preprocess(_params)
