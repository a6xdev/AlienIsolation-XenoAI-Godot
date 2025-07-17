extends Control


func _on_play_btn_pressed() -> void:
	if $check_debug_mode.button_pressed:
		Global.debug_mode = true
	else:
		Global.debug_mode = false
	
	get_tree().change_scene_to_file("res://scenes/test_world.tscn")

func _on_exit_btn_pressed() -> void:
	get_tree().quit()
