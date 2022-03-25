extends EmptyState

var parry:int = 0
var block_knockback: PoolIntArray = PoolIntArray()
var on_blocked_frames: int
var current_block_tick: int

func _first_time_loaded(_input: Dictionary):
	._first_time_loaded(_input)

func _load_state(_state: Dictionary):
	parry = _state.get('parry', 0)
	block_knockback = _state.get('block_knockback', PoolIntArray())
	on_blocked_frames = _state.get('on_blocked_frames', 0)
	current_block_tick = _state.get('current_block_tick', 0)
	
func _save_state() -> Dictionary:
	return {
		'parry': parry,
		'block_knockback': block_knockback,
		'on_blocked_frames': on_blocked_frames,
		'current_block_tick': current_block_tick
	}
	
func _on_player_preprocess(_input: Dictionary):
	
	if on_blocked_frames > current_block_tick:
		if(current_block_tick < block_knockback.size()):
			var knockback_calc = -1 if owner.forward == GlobalConstants.DIRECTION.RIGHT else 1
			knockback_calc *= block_knockback[current_block_tick]
			owner.move_speed_body(knockback_calc, 0)
		current_block_tick += 1
		if on_blocked_frames == current_block_tick:
			on_blocked_frames = 0
			current_block_tick = 0
		return
	
	var x_direction = _input.get(GlobalConstants.X_PLAYER_INPUT)
	if not check_if_inside_blocking(x_direction):
		owner.state_change('STANDING_STATE', _input)

func _on_hit(attack_stat: AttackData):
	on_blocked_frames = attack_stat.on_block_frames
	block_knockback = attack_stat.block_knockback
	current_block_tick = 0

func check_if_inside_blocking(x_direction: int) -> bool:
	if x_direction == 0:
		return false
	if x_direction == -1 and owner.forward == GlobalConstants.DIRECTION.LEFT:
		return false
	if x_direction == 1 and owner.forward == GlobalConstants.DIRECTION.RIGHT:
		return false
		
	var danger_boxes = get_tree().get_nodes_in_group("dangerbox")
	for d_box in danger_boxes:
		if d_box._is_inside(owner):
			return true
			
	return false
