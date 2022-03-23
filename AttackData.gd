extends Reference
class_name AttackData

var damage: int = 0
var stun_increase: int
var level: int
var on_hit_frames: int
var on_block_frames:int
var knockback: PoolIntArray
var block_knockback: PoolIntArray

func duplicate() -> AttackData:
	var duplo = get_script().new() as AttackData
	duplo.damage = damage
	duplo.stun_increase = stun_increase
	duplo.level = level
	duplo.on_hit_frames = on_hit_frames
	duplo.on_block_frames = on_block_frames
	duplo.knockback = knockback
	duplo.block_knockback = block_knockback
	return duplo
