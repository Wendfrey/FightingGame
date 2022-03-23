extends NinePatchRect

const ALPHA = .6

const dict_color = {
	'STANDING_STATE': Color(1,1,1, ALPHA),
	'FORWARD_DASH_STATE': Color(0,1,1,ALPHA),
	'BACK_DASH_STATE': Color(0,1,1,ALPHA),
	'ATTACK_STATE': Color(1,.5,.5,ALPHA)
}

func change_color_by_state(new_state: String):
	modulate = dict_color.get(new_state, Color(.5, .5, .5, ALPHA))
