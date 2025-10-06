extends Area3D
class_name ObjectToCrouch

func _ready() -> void:
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body:CharacterBody3D) -> void:
	if body is Player:
		body.is_crouched_to_hide = true

func _on_body_exited(body:CharacterBody3D) -> void:
	if body is Player:
		body.is_crouched_to_hide = false
