extends Resource
class_name PlayerResource

class Box:
	var rect:FixedRect = FixedRect.new()
	var name:String = ''
	class FixedRect:
		var ox:String
		var oy:String
		var sx:String
		var sy:String
		
class MovementData:
	var move_name:String = ''
	var frames:Array = []


export(Array, Dictionary) var hitboxes:Array
export(Array, Dictionary) var hurtboxes:Array
export(int) var health: int
export(int) var forward_walk_speed:int
export(int) var backward_walk_speed:int
