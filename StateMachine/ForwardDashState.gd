extends "res://stateMachine/NonBlockingState.gd"

var TICKS_MAX:int = 0
var TICKS_MOVEMENT:int = 0
var fixed_max_distance:int
export(int) var FORWARD_SPEED:int  = 65536 #Max distance  1px/tick

var current_tick:int  = 0
var origin_pos:SGFixedVector2 = SGFixed.vector2(0,0)

func _custom_ready():
	._custom_ready()
	var forward_d_fd = stateMachine.framedata["forward_dash"]
	TICKS_MOVEMENT = int(forward_d_fd["active"])
	TICKS_MAX = TICKS_MOVEMENT+ int(forward_d_fd["recovery_frames"])
	fixed_max_distance = forward_d_fd["distance"]
	print("active frames: {aframes}, rec. frames: {recframes}".format({"aframes": TICKS_MOVEMENT, "recframes":TICKS_MAX-TICKS_MOVEMENT}))
	
func _load_state(_state:Dictionary):
	current_tick = _state.get("current_tick", 0)
	origin_pos = SGFixed.vector2(_state["original_pos_x"], _state["original_pos_y"])
	
func _save_state() -> Dictionary:
	return {
		"current_tick": current_tick,
		"original_pos_x": origin_pos.x,
		"original_pos_y": origin_pos.y
	}

func _first_time_loaded(_params: Dictionary):
	._first_time_loaded(_params)
	current_tick = 0
	origin_pos.x = stateMachine.fixed_position.x
	origin_pos.y = stateMachine.fixed_position.y
	_on_player_preprocess(_params)

func _on_player_preprocess(_params: Dictionary):
	._on_player_preprocess(_params)
	if current_tick == TICKS_MAX:
		stateMachine.state_change("STANDING_STATE", _params)
		return
	elif current_tick < TICKS_MAX:
		current_tick += 1
		
	if current_tick <=  TICKS_MOVEMENT:
		var speed
		if stateMachine.forward == GlobalConstants.DIRECTION.RIGHT:
				speed = fixed_max_distance
		else:
				speed = -fixed_max_distance
		
		stateMachine.lerp_new_pos(origin_pos, SGFixed.vector2(speed, 0), current_tick, TICKS_MOVEMENT)
