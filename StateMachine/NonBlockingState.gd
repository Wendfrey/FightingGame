extends "res://stateMachine/EmptyState.gd"

const hitboxRes = preload("res://boxes/Hitbox.gd")

func _first_time_loaded(_params: Dictionary):
	._first_time_loaded(_params)

func _on_player_postprocess(_params):
	var collision_data = _check_player_hitted()
	if collision_data:
		_on_hit(_params, collision_data)

func _on_hit(_params:Dictionary, _collision_data:Dictionary):
	_params["oh_data"] = _collision_data["oh"]
	stateMachine.state_change("HITTED_STATE", _params)

func _check_player_hitted() -> Dictionary:
	var result = null
	var enemy_pl = str(stateMachine.get_enemy_player_type())
	var hitboxes = stateMachine.hurtboxArea.get_overlapping_areas()
	for box in hitboxes:
		if not box is hitboxRes:
			continue
		var hitbox = box as hitboxRes
		if not hitbox.collided:
			hitbox.collided = true
			result =  hitbox.get_hitbox_data()
	return result
