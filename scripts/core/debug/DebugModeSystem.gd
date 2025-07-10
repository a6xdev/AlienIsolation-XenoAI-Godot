extends Node3D

@onready var marker_target: MarkerTarget = $MarkerTarget

@export var xeno_ref:ActorXenomorph

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var camera = get_viewport().get_camera_3d()
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_direction = camera.project_ray_normal(event.position)

		var space_state = get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_origin + ray_direction * 1000.0
		query.collision_mask = 1
		query.exclude = []
		var result = space_state.intersect_ray(query)

		if result:
			var _position = result.position
			marker_target.global_position = Vector3(_position.x, 1.0, _position.z)
			marker_target.visible = true
			xeno_ref.navigation_agent.set_target_position(marker_target.global_position)
