extends Node

func parseFrameData(filepath:String) -> Dictionary:
	var result = {}
	var f_file = File.new()
	if(f_file.open(filepath, File.READ)):
		push_error("Error al abrir fichero")
		return result
		
	var jsonParserResult:JSONParseResult = JSON.parse(f_file.get_as_text())
	f_file.close()
	
	if(jsonParserResult.error):
		push_error("Error al decodificar json")
		return result
	
	result = jsonParserResult.result
	transform_json(result)
	return result
	
func transform_json(result:Dictionary):
	if(result.has("forward_dash") and result["forward_dash"].has("distance")):
		result["forward_dash"]["distance"] = string_to_fixed_dec(result["forward_dash"]["distance"])
	if(result.has("backward_dash") and result["backward_dash"].has("distance")):
		result["backward_dash"]["distance"] = string_to_fixed_dec(result["backward_dash"]["distance"])
	
	for attack in result["attacks"]:
		var attackFrameData = result["attacks"][attack]["frames"]
		for frame in attackFrameData.keys():
			if attackFrameData[frame].has("hitbox"):
				transform_hitbox(attackFrameData[frame]["hitbox"])
			attackFrameData[frame.to_int()] = attackFrameData[frame]
			attackFrameData.erase(frame)

func transform_hitbox(hitbox:Dictionary):
	hitbox["rect"]["o_x"] = string_to_fixed_dec(hitbox["rect"]["o_x"])
	hitbox["rect"]["o_y"] = string_to_fixed_dec(hitbox["rect"]["o_y"])
	hitbox["rect"]["s_x"] = string_to_fixed_dec(hitbox["rect"]["s_x"])
	hitbox["rect"]["s_y"] = string_to_fixed_dec(hitbox["rect"]["s_y"])
	
	hitbox["oh"]["knockback"] = string_to_fixed_dec(hitbox["oh"].get("knockback", "0"))
	hitbox["ob"]["knockback"] = string_to_fixed_dec(hitbox["ob"].get("knockback", "0"))
	match(hitbox.get("level", "MID").to_upper()):
		"LOW":
			hitbox["level"] = GlobalConstants.HIT_LEVEL.LOW
		"MID":
			hitbox["level"] = GlobalConstants.HIT_LEVEL.MID
		"HIGH":
			hitbox["level"] = GlobalConstants.HIT_LEVEL.HIGH
		

const FIXED_DEC_TENS = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000]
static func string_to_fixed_dec(str_fix_dec:String) -> int:
	if str_fix_dec.is_valid_integer():
		return str_fix_dec.to_int() << 0x10
	elif str_fix_dec.is_valid_float():
		var splitted_num = str_fix_dec.split(".", false, 1)
		var result = splitted_num[0].to_int() << 0xFF
		if(splitted_num.size() > 1):
			if(splitted_num[1].length() >= FIXED_DEC_TENS.size()):
				splitted_num[1] = splitted_num[1].left(FIXED_DEC_TENS.size())
			result += (splitted_num[1].to_int() << 16) / FIXED_DEC_TENS[splitted_num[1].size()]
		return result
	return 0
