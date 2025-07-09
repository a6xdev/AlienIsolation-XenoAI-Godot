extends Node

@export var actor:ActorXenomorph

var active:bool = false
var started:bool = false
var patrol_current_target = null

func _ready() -> void:
	if not actor:
		get_tree().quit()

func _physics_process(delta: float) -> void:
	if not started:
		patrol_current_target = MapManager.get_random_room()
		actor.navigation_agent.set_target_position(patrol_current_target.global_position)
		started = true
	
	if actor.navigation_agent.is_navigation_finished():
		patrol_current_target = MapManager.get_perfect_room(actor.global_position)
		actor.navigation_agent.set_target_position(patrol_current_target.global_position)
