extends Node

@export var actor:ActorXenomorph

var CurrentVent:VentWaypoint = null

#func _process(delta: float) -> void:
	#debug()

func update_behavior(delta:float):
	if not CurrentVent:
		CurrentVent = MapManager.get_perfect_duct(actor.global_position)
		actor.navigation_agent.set_target_position(CurrentVent.global_position)
	
	if actor.navigation_agent.is_navigation_finished() and not actor.IsInVent:
		actor.ToVent = true
		actor.IsInVent = true

func debug():
	ImGui.Begin("Vent Behavior")
	ImGui.Text("ToVent: %s" % actor.ToVent)
	ImGui.Text("IsInVent: %s" % actor.IsInVent)
	ImGui.End()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"vent_climb_in":
			await get_tree().create_timer(4.0).timeout
			actor.ToVent = false
		"vent_climb_out":
			actor.IsInVent = false
			CurrentVent = null
			actor.change_behavior(actor.behaviors_list.PATROL)
