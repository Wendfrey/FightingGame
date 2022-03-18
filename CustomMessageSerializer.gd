extends "res://addons/godot-rollback-netcode/MessageSerializer.gd"

enum INPUT {
	LEFT = 1
	RIGHT = 2
	UP = 4
	DOWN = 8
}

const input_path_mapping = {
	"/root/MainMenu/Spatial/ClientPlayer": 1,
	"/root/MainMenu/Spatial/ServerPlayer": 2
}
var input_path_mapping_flip = {}

func _init():
	for key in input_path_mapping:
		input_path_mapping_flip[input_path_mapping[key]] = key

func serialize_input(input: Dictionary) -> PoolByteArray:
	var output = StreamPeerBuffer.new()
	output.resize(10)
	var _data: int = 0
	
	output.put_u32(input['$'])
	output.put_u8(input.size()-1)
	
	for path in input:
		if path == '$':
			continue
		output.put_u8(input_path_mapping[path])
		
		var header = 0
		
		var player_input = input[path]	
		match player_input.get(GlobalConstants.X_PLAYER_INPUT, 0):
			1: header |= INPUT.RIGHT
			-1: header |= INPUT.LEFT
		match player_input.get(GlobalConstants.Y_PLAYER_INPUT, 0):
			1: header |= INPUT.UP
			-1: header |= INPUT.DOWN
		output.put_u8(header)
	
	output.resize(output.get_position())
	return output.data_array

func unserialize_input(serialized: PoolByteArray) -> Dictionary:
	var buffer = StreamPeerBuffer.new()
	buffer.put_data(serialized)
	buffer.seek(0)
	
	var output: Dictionary = {}
	
	output['$'] = buffer.get_u32()
	
	var element_counter = buffer.get_u8()
	for index in range(element_counter):
		var path = input_path_mapping_flip[buffer.get_u8()]
		
		var player_input = {}		
		var flagged_inputs = buffer.get_u8()
		if(flagged_inputs & INPUT.RIGHT == INPUT.RIGHT):
			player_input[GlobalConstants.X_PLAYER_INPUT] = 1
		elif(flagged_inputs & INPUT.LEFT == INPUT.LEFT):
			player_input[GlobalConstants.X_PLAYER_INPUT] = -1
		else:
			player_input[GlobalConstants.X_PLAYER_INPUT] = 0
			
		if(flagged_inputs & INPUT.UP == INPUT.UP):
			player_input[GlobalConstants.Y_PLAYER_INPUT] = 1
		elif(flagged_inputs & INPUT.DOWN == INPUT.DOWN):
			player_input[GlobalConstants.Y_PLAYER_INPUT] = -1
		else:
			player_input[GlobalConstants.Y_PLAYER_INPUT] = 0
			
		output[path] = player_input

	return output
