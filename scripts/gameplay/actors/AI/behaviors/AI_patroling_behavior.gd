extends Node

# Why did I use an export instead of just using @onready?
# Well, I don't really know either, it's just personal preference.
@export var actor:ActorXenomorph

var started:bool = false

var PatrolCurrentTarget = null
var WaitingForNewTarget := false

var IsGointToDuct:bool = false

var TargetIndex:int = 0
var GoToVentIndex:int = 0

func _ready() -> void:
	if not actor:
		get_tree().quit()

func update_behavior(delta: float) -> void:
	if not started:
		PatrolCurrentTarget = MapManager.get_random_room()
		actor.navigation_agent.set_target_position(PatrolCurrentTarget.global_position)
		started = true
	
	if actor.navigation_agent.is_navigation_finished() and not WaitingForNewTarget:
		TargetIndex += 1
		GoToVentIndex += 1
		WaitingForNewTarget = true
		
		if TargetIndex > 3 or (MapManager.player_current_room == MapManager.enemy_current_room):
			await get_tree().create_timer(5.0).timeout
			TargetIndex = 0
		
		if GoToVentIndex >= 6:
			actor.change_behavior(actor.behaviors_list.VENT)
			GoToVentIndex = 0
			started = false
		else:
			PatrolCurrentTarget = MapManager.get_perfect_room(actor.global_position)
			actor.navigation_agent.set_target_position(PatrolCurrentTarget.global_position)
		
		WaitingForNewTarget = false
