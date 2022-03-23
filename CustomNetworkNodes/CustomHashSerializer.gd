extends "res://addons/godot-rollback-netcode/HashSerializer.gd"

func unserialize_object(value: Dictionary):
	if value['_'] == 'AttackData':
		var data = AttackData.new()
		data.damage = value['damage']
		data.level = value['level']
		data.stun_increase = value['stun_increase']
		data.on_hit_frames = value['on_hit_frames']
		data.knockback = value['knockback']
		data.on_block_frames = value['on_block_frames']
		data.block_knockback =  value['block_knockback']
	return .unserialize_object(value)
	
func serialize_object(value: Object):
	if value is AttackData:
		return {
			_ = 'AttackData',
			damage = value.damage,
			level = value.level,
			stun_increase = value.stun_increase,
			on_hit_frames = value.on_hit_frames,
			knockback = value.knockback,
			on_block_frames = value.on_block_frames,
			block_knockback = value.block_knockback
		}
	return .serialize_object(value)
