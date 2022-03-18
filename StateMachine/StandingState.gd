extends "res://StateMachine/NonBlockingState.gd"

const speed: int = 7864

func _on_player_preprocess(_input: Dictionary):
	var x_direction:int  = _input.get(GlobalConstants.X_PLAYER_INPUT, 0)
	if get_owner()._get_command_result("DASH_COMMAND"):
		get_owner().state_change("DASH_STATE", _input)
	if x_direction != 0:
		get_owner().move_speed_body(x_direction * speed, 0)
