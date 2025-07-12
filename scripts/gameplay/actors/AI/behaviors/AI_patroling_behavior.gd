extends Node

@export var actor:ActorXenomorph

var started:bool = false

var patrol_current_target = null
var waiting_for_new_target := false

var IsGointToDuct:bool = false

var TargetIndex:int = 0
var GoToVentIndex:int = 0

func _ready() -> void:
	if not actor:
		get_tree().quit()

func update_behavior(delta: float) -> void:
	if not started:
		patrol_current_target = MapManager.get_random_room()
		actor.navigation_agent.set_target_position(patrol_current_target.global_position)
		started = true
	
	if actor.navigation_agent.is_navigation_finished() and not waiting_for_new_target:
		TargetIndex += 1
		GoToVentIndex += 1
		
		waiting_for_new_target = true
		
		if TargetIndex > 3 or (MapManager.player_current_room == MapManager.enemy_current_room):
			await get_tree().create_timer(5.0).timeout
			TargetIndex = 0
		
		if GoToVentIndex >= 6:
			actor.change_behavior(actor.behaviors_list.VENT)
			GoToVentIndex = 0
			started = false
		else:
			patrol_current_target = MapManager.get_perfect_room(actor.global_position)
			actor.navigation_agent.set_target_position(patrol_current_target.global_position)
		
		waiting_for_new_target = false
