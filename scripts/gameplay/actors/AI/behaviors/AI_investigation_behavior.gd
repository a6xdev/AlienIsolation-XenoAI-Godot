extends Node


enum investigation_type {
	DIRECT,
	INDIRECT
}

@export var actor:ActorXenomorph

var current_investigation_type:investigation_type = investigation_type.DIRECT
var current_target = null

var is_investigation:bool = false

func update_behavior(delta:float) -> void:
	if actor.navigation_agent.is_navigation_finished():
		actor.is_inspect = true
		await get_tree().create_timer(4.0).timeout
		actor.is_inspect = false
		actor.is_investigation = false
		actor.change_behavior(actor.behaviors_list.PATROL)

func set_place_to_investigate(place:Vector3) -> void:
	actor.navigation_agent.set_target_position(place)
	current_target = place
	Logger.print_msg(str("AI_WILL_INVESTIGATE"))
