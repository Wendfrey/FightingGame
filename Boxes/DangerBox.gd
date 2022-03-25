extends SGArea2D

onready var collision_shape = $DangerBoxShape
onready var shape = collision_shape.shape as SGRectangleShape2D
onready var despawn_timer = $DangerBoxDespawn
onready var dangerbox_visual = $Unlinker/DangerBoxVisual

var ignore_nodepath = ""
export(float) var elevation_offset
var collided:bool = false

const color = Color(1, 1, 0, 0.3)

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
	shape.extents.x = data.get("width", 0)
	shape.extents.y = data.get("height", 0)
	fixed_position.x = data.get("x", 0)
	fixed_position.y = data.get("y", 0)
	
	ignore_nodepath = data.get("ignore_nodepath", "")
	
	sync_to_physics_engine()
	
	despawn_timer.start(data.get("active_frames", 1))
	dangerbox_visual.rect_size = Vector2(SGFixed.to_float(shape.extents_x), SGFixed.to_float(shape.extents_y)) * 2	
	dangerbox_visual.rect_global_position = Vector2(SGFixed.to_float(fixed_position.x), SGFixed.to_float(fixed_position.y)) - dangerbox_visual.rect_size*0.5
	dangerbox_visual.modulate = color;
	
func _is_inside(player) -> bool:
	var player_path = str(player.get_path())
	if player_path == ignore_nodepath:
		return false
	var hits:Array = get_overlapping_bodies()
	for body in hits:
		if str(body.get_path()) == player_path:
			return true
			
	return false
			
func prepare_timeout():
	despawn_timer.ticks_left = 1

func is_about_to_dissapear() -> bool:
	return despawn_timer.ticks_left == 1


func _on_DangerBoxDespawn_timeout():
	SyncManager.despawn(self)
