extends "res://addons/fight_data_creator/src/data/BaseBoxFrameDataItem.gd"
class_name HitboxFrameDataItem

func _init(_frame_position, _active_frames).(_frame_position, _active_frames):
	pass

var id:int = 0
var hitsun_frames:int = 0
var blockstun_frames:int = 0
var hit_knockback: float = 0
var block_knockback: float = 0

func jsonify(_json_dict):
	.jsonify(_json_dict)
	_json_dict["hitstun_frames"] = hitsun_frames
	_json_dict["blockstun_frames"] = blockstun_frames
	_json_dict["hit_knockback"] = str(hit_knockback)
	_json_dict["block_knockback"] = str(block_knockback)
