extends Object
class_name FrameDataItem

const SET_PROPERTY = "change_property"
const SPAWN_ONLY_IF_PROPERTY = "spawn_only_if_property"

var frame_position: int = 0
var frame_length: int = 0 setget _set_frame_length
var _md_row: int = 0
var _md_color: Color = Color.red
var name:String = ""
var properties_interactions:Dictionary


func _init(_frame_position:int, _frame_length:int, __md_row:int = 0, __md_color:Color = Color.red):
	frame_position = _frame_position
	_set_frame_length(_frame_length)
	_md_row = __md_row
	_md_color = __md_color
	properties_interactions = {SET_PROPERTY: {}, SPAWN_ONLY_IF_PROPERTY: {}}

func _set_frame_length(_value):
	if(_value < 1):
		frame_length = 1
	else:
		frame_length = _value

func add_property_interaction(code:int, value):
	match (code):
		0:
			properties_interactions[SET_PROPERTY][value["name"]] = value["value"]
		1:
			properties_interactions[SPAWN_ONLY_IF_PROPERTY][value["id"]] = {
				"property": value["name"],
				"comp": value["comp"],
				"value": value["value"]
			}
		_:
			push_warning("Could not store property with code {code}".format({"code":code}))

func remove_property_interaction(code:int, identifier):
	match(code):
		0:
			properties_interactions[SET_PROPERTY].erase(identifier)
		1:
			properties_interactions[SPAWN_ONLY_IF_PROPERTY].erase(identifier)

func jsonify(_json_dict):
	_json_dict["name"] = name
	_json_dict["frame_start"] = frame_position
	_json_dict["frame_length"] = frame_length
	
	_json_dict["property_interactions"] = properties_interactions.duplicate()
