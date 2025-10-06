extends AIBehavior

@onready var actor_xenomorph: Xenomorph = $"../.."
@onready var sounds: Node3D = $"../../sounds"

var current_target:Vector3 = Vector3.ZERO

func start_behavior() -> void:
	pass

func update_behavior(_delta:float) -> void:
	if actor_xenomorph.agent.is_navigation_finished() and current_target != Vector3.ZERO:
		actor_xenomorph.is_inspecting = true
		
		if MapManager.xeno_current_room == MapManager.player_current_room:
			await get_tree().create_timer(5.0).timeout
			actor_xenomorph.set_xeno_state(actor_xenomorph.State.PATROL)
		else:
			await get_tree().create_timer(5.0).timeout
			actor_xenomorph.set_xeno_state(actor_xenomorph.State.PATROL)
			
		actor_xenomorph.is_inspecting = false
		sounds.play_sound(sounds.SoundType.INVESTIGATE)
		current_target = Vector3.ZERO

func reset_behavior() -> void:
	current_target = Vector3.ZERO

func set_place_to_investigate(place:Vector3) -> void:
	actor_xenomorph.set_xeno_state(actor_xenomorph.State.INVESTIGATE)
	actor_xenomorph.agent.set_target_position(place)
	current_target = place
