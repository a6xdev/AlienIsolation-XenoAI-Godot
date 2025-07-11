extends Node

@export var actor:ActorXenomorph

var started:bool = false

var patrol_current_target = null
var waiting_for_new_target := false

var target_index:int = 0

func _ready() -> void:
	if not actor:
		get_tree().quit()

func update_behavior(delta: float) -> void:
	if not started:
		patrol_current_target = MapManager.get_random_room()
		actor.navigation_agent.set_target_position(patrol_current_target.global_position)
		started = true
	
	if actor.navigation_agent.is_navigation_finished() and not waiting_for_new_target:
		target_index += 1
		
		waiting_for_new_target = true
		if target_index > 3 or (MapManager.player_current_room == MapManager.enemy_current_room):
			await get_tree().create_timer(5.0).timeout
			target_index = 0
		
		patrol_current_target = MapManager.get_perfect_room(actor.global_position)
		actor.navigation_agent.set_target_position(patrol_current_target.global_position)
		waiting_for_new_target = false
