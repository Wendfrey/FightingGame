extends FrameDataItem

var boxRect:Rect2

func _init(_frame_position, _active_frames).(_frame_position, _active_frames):
	boxRect = Rect2()


func jsonify(_json_dict):
	.jsonify(_json_dict)
	_json_dict["box_size"] = {
		"origin_x": str(boxRect.position.x),
		"origin_y": str(boxRect.position.y),
		"size_x": str(boxRect.size.x),
		"size_y": str(boxRect.size.y)
	}
