extends Node

# Why did I use an export instead of just using @onready?
# Well, I don't really know either, it's just personal preference.
@export var actor:ActorXenomorph

var CurrentVent:VentWaypoint = null

func update_behavior(delta:float):
	if not CurrentVent:
		CurrentVent = MapManager.get_perfect_duct(actor.global_position)
		actor.navigation_agent.set_target_position(CurrentVent.global_position)
	
	if actor.navigation_agent.is_navigation_finished() and not actor.IsInVent:
		actor.ToVent = true
		actor.IsInVent = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"vent_climb_in":
			actor.model.hide()
			# Here you can modify the timer for the AI to exit the vent.
			await get_tree().create_timer(4.0).timeout
			actor.ToVent = false
			actor.model.show()
		"vent_climb_out":
			actor.IsInVent = false
			CurrentVent = null
			actor.change_behavior(actor.behaviors_list.PATROL)
