# It is not used.

extends Node3D

@onready var marker_target: MarkerTarget = $MarkerTarget

@export var active:bool = false
@export_group("Flags")
@export var debug_ai_pathfinding:bool = false
@export var debug_set_target_position:bool = false
@export var debug_ai_vision_cones_draw:bool = false
@export var xeno_ref:ActorXenomorph

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and active:
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

func debug():
	ImGui.Begin("DebugMode")
	if ImGui.TreeNode("Flags"):
		if ImGui.Button("debug_ai_pathfinding: %s" % debug_ai_pathfinding):
			debug_ai_pathfinding = !debug_ai_pathfinding
		if ImGui.Button("debug_set_target_position: %s" % debug_set_target_position):
			debug_set_target_position = !debug_set_target_position
		if ImGui.Button("debug_ai_vision_cones_draw: %s" % debug_ai_vision_cones_draw):
			debug_ai_vision_cones_draw = !debug_ai_vision_cones_draw
		ImGui.EndPopup()
	ImGui.End()
