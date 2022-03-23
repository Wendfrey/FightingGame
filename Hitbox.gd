extends SGArea2D

onready var collision_shape = $SGCollisionShape2D
onready var shape = collision_shape.shape as SGRectangleShape2D
onready var despawn_timer = $HitboxDespawnTimer
onready var hitbox_visual = $Unlinker/HitboxVisual
onready var cam = get_node('/root/MainMenu/Spatial/Camera') as Camera

var ignore_nodepath = ""
var attack_data: AttackData
export(float) var elevation_offset
var collided:bool = false

const attack_color = {
	GlobalConstants.HIT_LEVEL.LOW: Color(0,0,1,.6),
	GlobalConstants.HIT_LEVEL.MID: Color(1,0,1,.6),
	GlobalConstants.HIT_LEVEL.HIGH: Color(1,0,0,.6)
}

func _load_state(_input: Dictionary):
	collided = _input.get('collided', false)

func _save_state():
	return {
		'collided': collided
	}

func _network_spawn_preprocess(data: Dictionary) -> Dictionary:
	if data.has("ignore_node"):
		data["ignore_nodepath"] = str((data["ignore_node"] as Node).get_path())
		data.erase("ignore_node")
	if data.has('hitbox_height'):
		data['hitbox_height'] = data['hitbox_height']/2
	if data.has('hitbox_width'):
		data['hitbox_width'] = data['hitbox_width']/2
	
	return data

func _network_spawn(data: Dictionary):
	shape.extents.x = data.get("hitbox_height", 0)
	shape.extents.y = data.get("hitbox_width", 0)
	fixed_position.x = data.get("hitbox_x", 0)
	fixed_position.y = data.get("hitbox_y", 0)
	attack_data = data.get("attack_data", AttackData.new()).duplicate()
	
	ignore_nodepath = data.get("ignore_nodepath", "")
	
	sync_to_physics_engine()
	
	despawn_timer.start(data.get("active_frames", 1))
	hitbox_visual.rect_size = Vector2(SGFixed.to_float(shape.extents_x), SGFixed.to_float(shape.extents_y)) * 2	
	hitbox_visual.rect_global_position = Vector2(SGFixed.to_float(fixed_position.x), SGFixed.to_float(fixed_position.y)) - hitbox_visual.rect_size*0.5
	hitbox_visual.modulate = attack_color.get(attack_data.level, Color.coral)
	
func _on_HitboxDespawnTimer_timeout():
	SyncManager.despawn(self)
	
func _network_process(_input: Dictionary):
	#We check for tick > 1 because there is a 1 frame inter
	if not collided:
		_check_collision()
	
func _check_collision():
	var hits:Array = get_overlapping_bodies()
	for body in hits:
		if ignore_nodepath == body.get_path():
			continue
		
		if (body.has_method("_on_hitbox_collision")):
			body._on_hitbox_collision(attack_data)
			collided = true
			
func prepare_timeout():
	despawn_timer.ticks_left = 1
	
