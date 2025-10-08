extends AIBehavior

@onready var actor_xenomorph: Xenomorph = $"../.."
@onready var sounds: Node3D = $"../../sounds"

var played_sound:bool = false
var is_chasing:bool = false

func start_behavior() -> void:
	pass

func update_behavior(_delta:float) -> void:
	if not played_sound:
		actor_xenomorph.ai_can_move = false
		await get_tree().create_timer(0.5).timeout
		sounds.play_sound(sounds.SoundType.CHASE)
		actor_xenomorph.ai_can_move = true
		played_sound = true
		is_chasing = true
		
	actor_xenomorph.agent.set_target_position(Global.player_ref.global_position)

func reset_behavior() -> void:
	played_sound = false
	is_chasing = false

#region SIGNALS
#endregion 
