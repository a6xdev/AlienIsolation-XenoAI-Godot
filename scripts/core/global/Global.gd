extends Node

var cursor_visible:bool = false

var player_ref:Player = null
var xenomorph_ref:Xenomorph = null

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("any_key"):
		cursor_visible = !cursor_visible
	
	if cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
