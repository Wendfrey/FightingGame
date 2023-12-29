extends "res://stateMachine/NonBlockingState.gd"

export(int) var speed: int = 78640

func _first_time_loaded(_params: Dictionary):
	._first_time_loaded(_params)
	_on_player_preprocess(_params)

func _on_player_preprocess(_params: Dictionary):
	var _input = _params.get('input', {})
	var x_direction:int  = _input.get(GlobalConstants.X_PLAYER_INPUT, 0)
	if _input.get(GlobalConstants.ATTACK_PLAYER_INPUT, false):
		stateMachine.state_change("ATTACK_STATE", _params)
	elif stateMachine._get_command_result("BackDashCommand"):
		stateMachine.state_change("BACK_DASH_STATE", _params)
	elif stateMachine._get_command_result("ForwardDashCommand"):
		stateMachine.state_change("FORWARD_DASH_STATE", _params)
	elif (check_if_inside_blocking(x_direction)):
			stateMachine.state_change("BLOCKING_STATE", _params)
	elif x_direction != 0:
		stateMachine.move_speed_body(x_direction * speed, 0)

func _on_hit(_params:Dictionary, _collision_data):
	var input = _params.get("input",{})
	
	var facing = stateMachine.forward
	var direction = 5 + input.get(GlobalConstants.X_PLAYER_INPUT, 0) + 3 * input.get(GlobalConstants.Y_PLAYER_INPUT, 0)
	
	
#	if GlobalConstants.BLOCKING_DIR[facing][attack_data.level] == direction:
	if direction % 3 == 0:
		print(stateMachine.name + " BLOCKED - Level 'not yet'")
		_params["on_block"] = _collision_data['ob']
		stateMachine.state_change("BLOCKING_STATE", _params)
	else:
		print(stateMachine.name + "HURT - Level 'not yet'")
		._on_hit(_params, _collision_data)

func check_if_inside_blocking(x_direction: int) -> bool:
	if x_direction == 0:
		return false
	if x_direction == -1 and stateMachine.forward == GlobalConstants.DIRECTION.LEFT:
		return false
	if x_direction == 1 and stateMachine.forward == GlobalConstants.DIRECTION.RIGHT:
		return false
	
	var danger_boxes = get_tree().get_nodes_in_group("dangerbox")
	for d_box in danger_boxes:
		if d_box._is_inside(stateMachine):
			print("is inside")
			return true
			
	return false
