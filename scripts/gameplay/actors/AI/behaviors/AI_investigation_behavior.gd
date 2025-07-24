extends Node

enum investigation_type {
	DIRECT,
	INDIRECT
}

# Why did I use an export instead of just using @onready?
# Well, I don't really know either, it's just personal preference.
@export var actor:ActorXenomorph

var current_investigation_type:investigation_type = investigation_type.DIRECT
var current_target = null

func update_behavior(delta:float) -> void:
	if actor.navigation_agent.is_navigation_finished():
		actor.IsInspect = true
		await get_tree().create_timer(4.0).timeout
		actor.IsInspect = false
		actor.IsInvestigation = false
		actor.change_behavior(actor.behaviors_list.PATROL)

func set_place_to_investigate(place:Vector3) -> void:
	actor.navigation_agent.set_target_position(place)
	current_target = place
	Logger.print_msg(str("AI_WILL_INVESTIGATE"))
