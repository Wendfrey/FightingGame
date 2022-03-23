extends "res://StateMachine/EmptyState.gd"

enum CollisionFlags{
	NO_COLLISION,
	BLOCKING_COLLISION,
	ATTACK_COLLISION
}

func get_has_collision() -> int:#
	return CollisionFlags.NO_COLLISION

func _on_hit(attack_data: AttackData):
	var _input = SyncManager.get_input_frame(SyncManager.current_tick).get_player_input(SyncManager.get_network_master()).get(str(owner.get_path())).duplicate(true)
	_input['on_hit_frames'] = attack_data.on_hit_frames
	_input['on_hit_knockback'] = attack_data.knockback
	_input['stun_increase'] = attack_data.stun_increase
	owner.state_change("HITTED_STATE", _input)
