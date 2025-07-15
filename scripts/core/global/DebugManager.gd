extends Node3D

@onready var marker_target := MarkerTarget.new()
@onready var free_camera := FreeLookCamera.new()

var xeno_ref:ActorXenomorph
var player_ref:Player

var active_free_camera:bool = false
var debug_ai_pathfinding:bool = false
var debug_set_target_position:bool = false
var debug_ai_vision_cones_draw:bool = false

func _ready() -> void:
	add_child(marker_target)
	add_child(free_camera)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and debug_set_target_position and Global.debug_mode:
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

func _process(delta: float) -> void:
	if Global.debug_mode:
		debug()

func debug():
	xeno_ref.debug()
	#player_ref.debug()
	
	ImGui.Begin("DebugMode")
	if ImGui.Button("actove_free_camera: %s" % active_free_camera):
		active_free_camera = !active_free_camera
		
		if active_free_camera:
			player_ref.camera.current = false
			free_camera.current = true
			free_camera.top_level = true
			free_camera.global_position = player_ref.global_position
		else:
			player_ref.camera.current = true
			free_camera.current = false
			free_camera.top_level = false
			free_camera.global_position = player_ref.global_position
			
	if ImGui.TreeNode("Flags"):
		if ImGui.Button("debug_ai_pathfinding: %s" % debug_ai_pathfinding):
			debug_ai_pathfinding = !debug_ai_pathfinding
		if ImGui.Button("debug_set_target_position: %s" % debug_set_target_position):
			debug_set_target_position = !debug_set_target_position
		if ImGui.Button("debug_ai_vision_cones_draw: %s" % debug_ai_vision_cones_draw):
			debug_ai_vision_cones_draw = !debug_ai_vision_cones_draw
		ImGui.TreePop()
	ImGui.End()
