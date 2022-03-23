extends Node
class_name EmptyState

func _first_time_loaded(_input: Dictionary):
	owner.hurtbox_visual.change_color_by_state(name)

func _load_state(_state: Dictionary):
	pass
	
func _save_state() -> Dictionary:
	return {}
	
func _on_player_preprocess(_input: Dictionary):
	pass

func _on_player_process(_input:Dictionary):
	pass
	
func _on_player_postprocess(_input: Dictionary):
	pass

func _on_hit(attack_stat: AttackData):
	pass
