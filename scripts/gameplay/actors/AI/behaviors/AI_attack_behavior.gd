extends Node

@onready var attack_camera_3d: Camera3D = $"../../model/xenomorph_main/Skeleton3D/AttackCamera/AttackCamera3D"

# Why did I use an export instead of just using @onready?
# Well, I don't really know either, it's just personal preference.
@export var actor:ActorXenomorph

var player:Player

func attack() -> bool:
	# anim_position is a Marker3D located in the player's scene.
	# It serves as the reference point where the Alien should be when performing the attack animation.
	var anim_position = player.alien_anim_position.global_position
	anim_position.y = player.global_position.y
	
	actor.global_position = lerp(actor.global_position, anim_position, 1.0)
	actor.rotate_towards_target(player.global_position)
	
	actor.IsAttacking = true
	attack_camera_3d.current = true
	return true

func end_game():
	# This function is triggered when the Xenomorph performs its attack.
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
