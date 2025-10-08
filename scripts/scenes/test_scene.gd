extends Node3D

@onready var actor_player: Player = $actor/actor_player
@onready var actor_xenomorph: Xenomorph = $actor/actor_xenomorph
@onready var end_game_ui: Control = $UI/EndGame
@onready var ambient_sound_system: AudioStreamPlayer = $AmbientSoundSystem

var player_pos:Vector3
var xeno_pos:Vector3

func _ready() -> void:
	player_pos = actor_player.global_position
	xeno_pos = actor_xenomorph.global_position
	
func reset_game():
	end_game_ui.show()
	
	actor_player.global_position = player_pos
	actor_player.global_rotation = Vector3.ZERO
	
	actor_xenomorph.global_position = xeno_pos
	actor_xenomorph.global_rotation = Vector3.ZERO
	
	actor_xenomorph.vision_system.reset_all()
	actor_xenomorph.ai_patrol.reset_behavior()
	actor_xenomorph.ai_investigate.reset_behavior()
	
	actor_xenomorph.ai_patrol.set_random_target()
	actor_xenomorph.set_xeno_state(actor_xenomorph.State.PATROL)
	
	actor_xenomorph.ai_chase.reset_behavior() # needs be reseted after set new state
	
	ambient_sound_system.stop()
	
	await get_tree().create_timer(3.0).timeout
	
	ambient_sound_system.play()
	
	actor_xenomorph.ai_can_move = true
	actor_xenomorph.ai_can_see = true
	actor_xenomorph.is_attacking = false
	
	end_game_ui.hide()
	
func _on_actor_xenomorph_kill_player() -> void:
	reset_game()
