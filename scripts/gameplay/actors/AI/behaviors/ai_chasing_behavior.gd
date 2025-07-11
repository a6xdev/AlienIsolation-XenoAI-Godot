extends Node

@export var actor:ActorXenomorph

var actor_being_chased:Player

func update_behavior(delta:float) -> void:
	if actor_being_chased:
		actor.navigation_agent.set_target_position(actor_being_chased.global_position)
		
	if actor.navigation_agent.is_navigation_finished():
		pass

func _on_vision_system_actor_spotted(body: Player) -> void:
	actor.change_behavior(actor.behaviors_list.CHASE)
	actor_being_chased = body
	
func _on_vision_system_actor_lost() -> void:
	actor_being_chased = null
	#actor.change_behavior(actor.behaviors_list.PATROL)
