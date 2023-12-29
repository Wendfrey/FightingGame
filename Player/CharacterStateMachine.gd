extends "res://player/BaseCharacterRollback.gd"
class_name CharacterStateMachine

onready var state_list = $StateList
var current_state: EmptyState


# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = state_list.get_node(initial_state)

	if not current_state:
		push_error(initial_state + " not found")

func _save_state():
	var _state = ._save_state()
	
	_state["state_name"] = current_state.get_name()
	_state["state_data"] = current_state._save_state()
	
	return _state;

func _load_state(_state):
	._load_state(_state)
	current_state = state_list.get_node(_state.get("state_name"))
	current_state._load_state(_state.get("state_data", {}))
	hurtbox_visual.change_color_by_state(current_state.name)

func _network_preprocess(_input):
	._network_preprocess(_input)
	current_state._on_player_preprocess({
		"input": _input.duplicate()
	})
	

func _network_process(_input):
	._network_process(_input)
	current_state._on_player_process({
		"input": _input.duplicate()
	})
	

func _network_postprocess(_input):
	._network_postprocess(_input)
	current_state._on_player_postprocess({
		"input": _input.duplicate()
	})
	
func state_change(new_state: String, _last_input: Dictionary, call_first_time: bool = true):
	hurtbox_visual.change_color_by_state(new_state)
	if current_state.name != new_state:
		current_state = state_list.get_node(new_state)
	if call_first_time:
		current_state._first_time_loaded(_last_input)

func get_attack_data(attack_name) -> Dictionary:
	return framedata.get("attacks", {}).get(attack_name, {}).duplicate(true)
