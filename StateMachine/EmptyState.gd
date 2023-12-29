extends Node
class_name EmptyState

var stateMachine

func _ready():
	yield(owner,"ready")
	stateMachine = owner
	_custom_ready()
	
func _custom_ready():
	pass

func _first_time_loaded(_params: Dictionary):
	stateMachine.hurtbox_visual.change_color_by_state(name)

func _load_state(_state: Dictionary):
	pass
	
func _save_state() -> Dictionary:
	return {}
	
func _on_player_preprocess(_params: Dictionary):
	pass

func _on_player_process(_params:Dictionary):
	pass
	
func _on_player_postprocess(_params: Dictionary):
	pass

func _on_hit(_params:Dictionary, _collision_data:Dictionary):
	pass
