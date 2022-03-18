extends Reference
class_name BaseCommand

func _load_state(_state: Dictionary):
	pass
	
func _save_state() -> Dictionary:
	return {}
	
func _player_process(_input: Dictionary):
	pass

func _player_preprocess(_input:Dictionary):
	pass

func _player_postprocess(_input:Dictionary):
	pass
	
func _is_input_command_valid() -> bool:
	return false
	
func get_key() -> String:
	return ""
