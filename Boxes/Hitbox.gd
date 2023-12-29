extends SGArea2D

signal whiffed(whiff_data)

onready var collision_shape = $SGCollisionShape2D
onready var shape = collision_shape.shape as SGRectangleShape2D
onready var despawn_timer = $HitboxDespawnTimer
onready var hitbox_visual = $Unlinker/HitboxVisual

var ignore_nodepath = ""
var hitbox_frame_data:Dictionary = {}
var collided:bool = false
var attack_data:Dictionary = {}
var whiff_data:Dictionary = {}

const attack_color = {
	GlobalConstants.HIT_LEVEL.LOW: Color(0,0,1,.6),
	GlobalConstants.HIT_LEVEL.MID: Color(1,0,1,.6),
	GlobalConstants.HIT_LEVEL.HIGH: Color(1,0,0,.6)
}

func _load_state(_input: Dictionary):
	collided = _input.get('collided', false)
	attack_data = _input.get('attack_data', {})
	whiff_data = _input.get("whiff_data", {})

func _save_state():
	return {
		'collided': collided,
		'attack_data': attack_data.duplicate(true),
		'whiff_data': whiff_data.duplicate(true),
	}

func _network_spawn_preprocess(data: Dictionary) -> Dictionary:
	if data.has("ignore_node"):
		data["ignore_nodepath"] = str((data["ignore_node"] as Node).get_path())
		data.erase("ignore_node")
	if data.has('rect'):
		data['rect']['s_x'] = data['rect']['s_x']/2
		data['rect']['s_y'] = data['rect']['s_y']/2
	
	return data

func _network_spawn(data: Dictionary):
	var rect = data.get("rect", {})
	shape.extents.x = rect.get("s_x", 0)
	shape.extents.y = rect.get("s_y", 0)
	fixed_position.x = rect.get("o_x", 0)
	fixed_position.y = rect.get("o_y", 0)
	
	hitbox_frame_data = {
		"oh": data["oh"],
		"ob": data["ob"],
		"level": data["level"]
	}
	
	whiff_data = data.get("ow",{})
	
	ignore_nodepath = data.get("ignore_nodepath", "")
	despawn_timer.start(data.get("active", 1))
	
	collision_layer = data.get("enemy_player_collision_layer", 0)
	sync_to_physics_engine()
	
	hitbox_visual.rect_size = Vector2(SGFixed.to_float(shape.extents_x), SGFixed.to_float(shape.extents_y)) * 2	
	hitbox_visual.rect_global_position = Vector2(SGFixed.to_float(fixed_position.x), SGFixed.to_float(fixed_position.y)) - hitbox_visual.rect_size*0.5
	hitbox_visual.modulate = attack_color.get(data['level'], Color.coral)
	
func _on_HitboxDespawnTimer_timeout():
	if(not collided):
		emit_signal("whiffed", whiff_data)
	SyncManager.despawn(self)

func prepare_timeout():
	despawn_timer.ticks_left = 1

func get_hitbox_data()->Dictionary:
	return hitbox_frame_data
