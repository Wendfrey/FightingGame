extends "res://StateMachine/NonBlockingState.gd"

export(int) var speed: int = 78640

func _first_time_loaded(_input: Dictionary):
	._first_time_loaded(_input)
	_on_player_preprocess(_input)

func _on_player_preprocess(_input: Dictionary):
	var x_direction:int  = _input.get(GlobalConstants.X_PLAYER_INPUT, 0)
	if _input.get(GlobalConstants.ATTACK_PLAYER_INPUT, false):
		owner.state_change("ATTACK_STATE", _input)
	elif owner._get_command_result("BackDashCommand"):
		owner.state_change("BACK_DASH_STATE", _input)
	elif owner._get_command_result("ForwardDashCommand"):
		owner.state_change("FORWARD_DASH_STATE", _input)
	elif (check_if_inside_blocking(x_direction)):
			owner.state_change("BLOCKING_STATE", _input)
	elif x_direction != 0:
		owner.move_speed_body(x_direction * speed, 0)

func _on_hit(attack_data: AttackData):
	var s_input = SyncManager.get_input_frame(SyncManager.current_tick).get_player_input(owner.get_network_master())
	var input = s_input.get(str(owner.get_path()))
	
	var facing = owner.forward
	var direction = 5 + input.get(GlobalConstants.X_PLAYER_INPUT, 0) + 3 * input.get(GlobalConstants.Y_PLAYER_INPUT, 0)
	
	if GlobalConstants.BLOCKING_DIR[facing][attack_data.level] == direction:
		print(owner.name + " BLOCKED - Level " + str(attack_data.level))
	else:
		print(owner.name + "HURT - Level " + str(attack_data.level))
		._on_hit(attack_data)

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
			print("is inside")
			return true
			
	return false
