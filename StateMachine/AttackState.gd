extends "res://stateMachine/NonBlockingState.gd"

var HitBoxInstance = preload("res://Boxes/Hitbox.tscn")
var DangerBoxInstance = preload("res://Boxes/DangerBox.tscn")

var tick_count = 0
var tick_max:int = 0
var hitbox_path: String = ''
var dangerbox_path: String = ''
var attack_name:String = ''

#We do not need to save this, we can load it again with attack name
var attack_framedata:Dictionary = {}
var properties:Dictionary = {}

var signal_name_hitbox:String = ""
var arraylist_cancels:Array = []

func _custom_ready():
	._custom_ready()
	SyncManager._spawn_manager.connect("scene_spawned", self, "_on_scene_spawned")
	SyncManager._spawn_manager.connect("scene_despawned", self, "_on_scene_despawned")
	signal_name_hitbox = "hitbox_pl_" + str(stateMachine.player_type)
	
func _first_time_loaded(_params: Dictionary):
	._first_time_loaded(_params)
	attack_name = _params.get("attack_name", "basic_attack")
	attack_framedata = stateMachine.get_attack_data(attack_name)
	assert(not attack_framedata.empty(), "Attack frame data is empty")
	
	properties = attack_framedata.get("properties",{}).duplicate()
	tick_count = 0
	tick_max = attack_framedata["duration"]
	arraylist_cancels.clear()
	
	spawn_dangerbox()
	_on_player_preprocess(_params)

func _load_state(_status: Dictionary):
	tick_count = _status.get("tick_count", 0)
	tick_max = _status.get("tick_max", 0)
	properties = _status.get('properties', {})
	hitbox_path = _status.get('hitbox_path', '')
	dangerbox_path = _status.get('dangerbox_path', '')
	attack_name = _status.get('attack_name', '')
	arraylist_cancels = _status.get('arraylist_cancels', [])
	
	attack_framedata = stateMachine.get_attack_data(attack_name)
	assert(not attack_framedata.empty(), "Attack frame data is empty")

func _save_state() -> Dictionary:
	return{
		"tick_count": tick_count,
		"tick_max": tick_max,
		'hitbox_path': hitbox_path,
		'dangerbox_path': dangerbox_path,
		'attack_name': attack_name,
		'properties': properties.duplicate(),
		'arraylist_cancels': arraylist_cancels.duplicate(true)
	}

func _on_player_preprocess(_params:Dictionary):	
	if attack_framedata["frames"].has(tick_count):
		for order in attack_framedata["frames"][tick_count]:
			var frame_data = attack_framedata["frames"][tick_count][order]
			match(order):
				"hitbox":
					spawn_hitbox(
						frame_data
					)
				"force_exit":
					if(force_exit(frame_data)):
						stateMachine.state_change("STANDING_STATE", _params)
				"cancel":
					cancel_move(frame_data)
	
	#Done from end to beggining in case of problems while erasing
	for c_index in range(arraylist_cancels.size()-1, -1, -1):
		var cancel_data = arraylist_cancels[c_index]
		if cancel_data["active"] == 0:
			arraylist_cancels.remove(c_index)
			
	for cancel_data in arraylist_cancels:
		cancel_data["active"] = cancel_data["active"] - 1
		if(stateMachine._get_command_result(cancel_data["input"])):
			print("Cancel into: " + str(cancel_data["into"]))
			match(cancel_data["into"]):
				"forward_dash":
					stateMachine.state_change("FORWARD_DASH_STATE", _params)
				"backward_dash":
					stateMachine.state_change("BACK_DASH_STATE", _params)
				var into:
					_params["attack_name"] = into
					_first_time_loaded(_params)
			return
	
	if (tick_count >= tick_max):
		stateMachine.state_change("STANDING_STATE", _params)
		return
	
	tick_count += 1

func _on_hit(_params:Dictionary, _collision_data:Dictionary):
	var hitbox = get_node(hitbox_path)
	var dangerbox = get_node(dangerbox_path)
#	We want to check if this frame the enemy player was in range of the collision, so remove it next preprocess frame 
	if hitbox and not hitbox.is_queued_for_deletion():
		hitbox.prepare_timeout()
	if dangerbox and not dangerbox.is_queued_for_deletion():
		dangerbox.prepare_timeout()
		
	._on_hit(_params, _collision_data)

func spawn_hitbox(hitbox_data:Dictionary):
	var distance:int = 1 if stateMachine.forward == GlobalConstants.DIRECTION.RIGHT else -1

	#	if  y_input == 1:
	#		attack_data.level = GlobalConstants.HIT_LEVEL.HIGH
	#	elif y_input == 0:
	#		attack_data.level = GlobalConstants.HIT_LEVEL.MID
	#	else:
	#		attack_data.level = GlobalConstants.HIT_LEVEL.LOW

	hitbox_data["rect"]["o_x"] = distance * (hitbox_data["rect"]["o_x"]) + stateMachine.fixed_position.x
	hitbox_data["rect"]["o_y"] = hitbox_data["rect"]["o_y"] + stateMachine.fixed_position.y
	hitbox_data["enemy_player_collision_layer"] = stateMachine.get_enemy_player_type()
	var node = SyncManager.spawn("Hitbox", stateMachine.get_parent(), HitBoxInstance, hitbox_data, true, signal_name_hitbox)
	hitbox_path = str(node.get_path())

func spawn_dangerbox():
	var distance = SGFixed.ONE * (16 if stateMachine.forward == GlobalConstants.DIRECTION.RIGHT else -16)
	distance += stateMachine.fixed_position.x
	var _extra = {
		'height': SGFixed.ONE * 48,
		'width': SGFixed.ONE * 64,
		'x': distance,
		'y': stateMachine.fixed_position.y,
		'active_frames': 12,
		'ignore_node': stateMachine
	}
	var node = SyncManager.spawn('Dangerbox', stateMachine.get_parent(), DangerBoxInstance, _extra)
	dangerbox_path = str(node.get_path())

func force_exit(force_exit_data:Dictionary) -> bool:
	for _prop in force_exit_data["if"]:
		if not properties.has(_prop):
			return false
		if properties[_prop] != force_exit_data["if"][_prop]:
			return false
	return true

func cancel_move(cancel_array_data:Array):
	for cancel_data in cancel_array_data:
		var add = true
		if cancel_data.has("if"):
			var _prop = cancel_data["if"].keys()[0]
			if (not properties.has(_prop)):
				add = false
				push_warning("Trying to compare unknown property")
			elif (properties[_prop] != cancel_data["if"][_prop]):
				add = false
		
		if(add):
			arraylist_cancels.append({
				"active": cancel_data["active"],
				"into": cancel_data["into"],
				"input": cancel_data["input"]
			})

func _on_attack_whiff(whiff_data:Dictionary):
	if whiff_data.empty():
		return
	
	if whiff_data.has("set"):
		for _prop in whiff_data["set"]:
			if properties.has(_prop):
				properties[_prop] = whiff_data["set"][_prop]

#SCENE SIGNALS
func _on_scene_spawned(signal_name, spawned_node, scene, data):
	if signal_name == signal_name_hitbox:
		spawned_node.connect("whiffed", self, "_on_attack_whiff")
		
func _on_scene_despawned(signal_name, node):
	if signal_name == signal_name_hitbox:
		node.disconnect("whiffed", self, "_on_attack_whiff")
