extends "res://StateMachine/NonBlockingState.gd"

var on_hit_knockback:PoolIntArray
var ticks_counter: int
var max_ticks:int
var direction: int

func _first_time_loaded(_input: Dictionary):
	on_hit_knockback = _input.get("on_hit_knockback", PoolIntArray())
	ticks_counter = 0
	max_ticks = _input.get("on_hit_frames", 0)
	direction = -1 if owner.forward == GlobalConstants.DIRECTION.RIGHT else 1
	
	#clear _input from custom keys
	_input.erase('on_hit_knockback')
	_input.erase('on_hit_frames')
	_input.erase('stun_increase')
	
	._on_player_preprocess(_input)

func _load_state(_input: Dictionary):
	on_hit_knockback = _input['on_hit_knockback']
	ticks_counter = _input['ticks_counter']
	max_ticks = _input['max_ticks']
	direction = _input['direction']
	
func _save_state() -> Dictionary:
	return {
		'on_hit_knockback': on_hit_knockback,
		'ticks_counter': ticks_counter,
		'max_ticks': max_ticks,
		'direction': direction
	}
	
func _on_player_preprocess(_input: Dictionary):
	if (ticks_counter == max_ticks):
		owner.state_change('STANDING_STATE', _input)
		return
		
	if(on_hit_knockback.size() > ticks_counter):
		owner.move_speed_body(on_hit_knockback[ticks_counter] * direction, 0)
	
	ticks_counter += 1
	
func _on_hit(attack_data:AttackData):
	var _input = SyncManager.get_input_frame(SyncManager.current_tick).get_player_input(owner.get_network_master()).get(str(owner.get_path()))
	
	_input['on_hit_knockback'] = attack_data.knockback
	_input['on_hit_frames'] = attack_data.on_hit_frames
	_input['stun_increase'] = attack_data.stun_increase
	_first_time_loaded(_input)
