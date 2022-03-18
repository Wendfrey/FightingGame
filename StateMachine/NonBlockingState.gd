extends "res://StateMachine/EmptyState.gd"

enum CollisionFlags{
	NO_COLLISION,
	BLOCKING_COLLISION,
	ATTACK_COLLISION
}

func get_has_collision() -> int:
#	get_owner().kinematicBody.sync_to_physics_engine()
#	var nodes = get_tree().get_nodes_in_group("AttackCollision")
#	
#	for sNode in nodes:
#		if not (sNode is SGArea2D):
#			assert(sNode.get_name() + " is not of type SGArea2D")
#			continue
#		var area:SGArea2D = sNode as SGArea2D
#		var bodies = area.get_overlapping_bodies(false)
#		for body in bodies:
#			if not(body is SGKinematicBody2D):
#				continue
#			if (body == get_owner().kinematicBody):
#				return CollisionFlags.ATTACK_COLLISION
#
	return CollisionFlags.NO_COLLISION
