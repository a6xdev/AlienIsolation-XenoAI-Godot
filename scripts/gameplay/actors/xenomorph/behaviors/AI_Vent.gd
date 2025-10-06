extends AIBehavior

@onready var actor_xenomorph: Xenomorph = $"../.."
@onready var vent_climb_in: AudioStreamPlayer3D = $"../../sounds/VentClimbIn"

var current_vent_target:Vector3 = Vector3.ZERO

var is_going_to_duct:bool = false
var is_leaving_to_duct:bool = false

func start_behavior() -> void:
	pass

func update_behavior(_delta:float) -> void:
	
	if not actor_xenomorph.is_on_duct and not is_going_to_duct:
		var vent_target = MapManager.get_perfect_duct(actor_xenomorph.global_position)
		actor_xenomorph.agent.set_target_position(vent_target.global_position)
		is_going_to_duct = true
	
	if actor_xenomorph.agent.is_navigation_finished() and is_going_to_duct and not is_leaving_to_duct:
		actor_xenomorph.physical_bone_simulator.physical_bones_stop_simulation()
		is_going_to_duct = false
		actor_xenomorph.is_on_duct = true
		vent_climb_in.play()

func reset_vent_behavior() -> void:
	current_vent_target = Vector3.ZERO
	is_going_to_duct = false
	is_leaving_to_duct = false
