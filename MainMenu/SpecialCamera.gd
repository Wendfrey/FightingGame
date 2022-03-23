extends Camera

onready var camera2d = $Camera2D

func _ready():
#	var zoom_value = 1 + GlobalConstants.WORLD_TO_PIXEL / (get_viewport().size.x / (deg2rad(fov) * global_transform.origin.z))
	var zoom_value = deg2rad(fov) * global_transform.origin.z * 2 * GlobalConstants.WORLD_TO_PIXEL / get_viewport().size.x
	
#	camera2d.zoom = Vector2.ONE * zoom_value
#	print(camera2d.zoom)
	print("Zoom value: %s" % [zoom_value] )

#func _process(delta):
#	var zoom_value = 1 + GlobalConstants.WORLD_TO_PIXEL / (get_viewport().size.x / deg2rad(fov) * global_transform.origin.z) 
#	camera2d.zoom = Vector2.ONE * zoom_value
