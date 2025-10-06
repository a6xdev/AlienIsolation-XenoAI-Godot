extends AIBehavior

@onready var actor_xenomorph: Xenomorph = $"../.."
@onready var sounds: Node3D = $"../../sounds"

var played_sound:bool = false

func start_behavior() -> void:
	pass

func update_behavior(_delta:float) -> void:
	actor_xenomorph.agent.set_target_position(Global.player_ref.global_position)
	
	if not played_sound:
		sounds.play_sound(sounds.SoundType.PATROL)
		played_sound = true

func reset_behavior() -> void:
	played_sound = false

#region SIGNALS
#endregion 
