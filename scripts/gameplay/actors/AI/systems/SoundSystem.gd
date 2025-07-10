extends Node

@onready var ai_investigatin_behavior: Node = $"../../behaviors/AI_investigatin_behavior"

@export var actor:ActorXenomorph

func _on_sound_detector_area_entered(area: Area3D) -> void:
	if area is SoundEvent:
		actor.change_behavior(actor.behaviors_list.INVESTIGATE)
		ai_investigatin_behavior.set_place_to_investigate(area.global_position)
		Logger.print_msg(str("AI_HEARD_SOUND"))
