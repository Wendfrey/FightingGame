extends "res://StateMachine/NonBlockingState.gd"

var HitBoxInstance = preload("res://Boxes/Hitbox.tscn")
var DangerBoxInstance = preload("res://Boxes/DangerBox.tscn")

var tick_count = 0
var nodepath_reference: String

func _first_time_loaded(_input: Dictionary):
	._first_time_loaded(_input)
	tick_count = 0
	spawn_dangerbox()

func _load_state(_input: Dictionary):
	tick_count = _input.get("tick_count", 0)
	nodepath_reference = _input.get('nodepath_reference', '')

func _save_state() -> Dictionary:
	return{
		"tick_count": tick_count,
		'nodepath_reference': nodepath_reference
	}

func _on_player_process(_input:Dictionary):
	tick_count += 1
	
	if (tick_count >= 20):
		owner.state_change("STANDING_STATE", _input)
		return
	
	if tick_count == 9:
		spawn_hitbox(_input.get(GlobalConstants.Y_PLAYER_INPUT,0))
	
func spawn_hitbox(y_input: int):
	var distance = SGFixed.ONE * 32
	if(owner.forward == GlobalConstants.DIRECTION.LEFT):
		distance *= -1
#	TODO this should be in a file or resource
	var attack_data:AttackData = AttackData.new()
	attack_data.on_hit_frames = 11
	attack_data.knockback = PoolIntArray([65536,65536,65536,65536,65536,
	65536,65536,65536,65536,65536,65536])
	attack_data.on_block_frames = 11
	attack_data.block_knockback = PoolIntArray([SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,
	SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,SGFixed.HALF,SGFixed.HALF])
	attack_data.stun_increase = 0 #DOES NOTHING FOR NOW#
####
	if  y_input == 1:
		attack_data.level = GlobalConstants.HIT_LEVEL.HIGH
	elif y_input == 0:
		attack_data.level = GlobalConstants.HIT_LEVEL.MID
	else:
		attack_data.level = GlobalConstants.HIT_LEVEL.LOW
			
	var data = {
		"hitbox_height": SGFixed.ONE*32,
		"hitbox_width": SGFixed.ONE*32,
		"hitbox_x": owner.fixed_position.x + distance,
		"hitbox_y": owner.fixed_position.y,
		"attack_data": attack_data,
		"ignore_node": owner,
		"active_frames": 3
	}
	var node = SyncManager.spawn("Hitbox", owner.get_parent(), HitBoxInstance, data)
	nodepath_reference = str(node.get_path())
	node._check_collision()

func spawn_dangerbox():
	var distance = SGFixed.ONE * (16 if owner.forward == GlobalConstants.DIRECTION.RIGHT else -16)
	distance += owner.fixed_position.x
	var _extra = {
		'height': SGFixed.ONE * 48,
		'width': SGFixed.ONE * 64,
		'x': distance,
		'y': owner.fixed_position.y,
		'active_frames': 20,
		'ignore_node': owner
	}
	SyncManager.spawn('Dangerbox', owner.get_parent(), DangerBoxInstance, _extra)

func _on_hit(attack_state: AttackData):
	var node = get_node(nodepath_reference)
#	We want to check if this frame the enemy player was in range of the collision, so remove it next preprocess frame 
	if node:
		node.prepare_timeout()
		
	._on_hit(attack_state)
	
