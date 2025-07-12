extends Node

@onready var attack_camera_3d: Camera3D = $"../../model/xenomorph_main/Skeleton3D/AttackCamera/AttackCamera3D"

@export var actor:ActorXenomorph
var player:Player

func attack() -> bool:
	var anim_position = player.alien_anim_position.global_position
	anim_position.y = player.global_position.y
	
	actor.global_position = lerp(actor.global_position, anim_position, 1.0)
	actor.rotate_towards_target(player.global_position)
	
	actor.IsAttacking = true
	attack_camera_3d.current = true
	return true

func end_game():
	# when xenomorph makes your attack animation
	# You can see the function being called in the "attack1" animation in the AnimationPlayer.
	
	player.kill_player()

#region SIGNALS
func _on_attack_area_body_entered(body: Node3D) -> void:
	if actor.current_behaviors_list == actor.behaviors_list.CHASE and body is Player:
		player = body
		attack()
func _on_attack_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player = null
#endregion
