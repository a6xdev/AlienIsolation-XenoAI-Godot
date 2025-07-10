extends CharacterBody3D
class_name ActorXenomorph

@onready var animation_player: AnimationPlayer = $model/AnimationPlayer
@onready var animation_tree: AnimationTree = $model/AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent

@onready var vision_system: Node = $systems/VisionSystem

@onready var ai_chasing_behavior: Node = $behaviors/AI_chasing_behavior
@onready var ai_investigatin_behavior: Node = $behaviors/AI_investigatin_behavior
@onready var ai_patroling_behavior: Node = $behaviors/AI_patroling_behavior

var move_dir:Vector3 = Vector3.ZERO

enum behaviors_list {
	PATROL,
	INVESTIGATE,
	CHASE
}

var current_behaviors_list:behaviors_list = behaviors_list.PATROL

@export_group("Actor Settings")
@export var can_move:bool = true
@export var can_see_actors:bool = false
@export var can_listen:bool = false

@export_subgroup("Speed Settings")
@export var walk_speed:float = 2.0
@export var run_speed:float = 5.0
@export var rotation_speed:int = 2
var accel_speed:float = 30.0

var current_speed:float = 0.0
var current_speed_anim:float = 0.0
var target_speed:float = 0.0

var is_investigation:bool = false
var is_inspect:bool = false
var is_with_fear:bool = false
var is_crawling:bool = false

# Movement
var movement_target:Vector3

#region GODOT FUNCTIONS
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	movement_controller(delta)
	animation_controller(delta)
	
	if can_see_actors: vision_system.update_system(delta)
	
	match current_behaviors_list:
		behaviors_list.PATROL:
			ai_patroling_behavior.update_behavior(delta)
		behaviors_list.INVESTIGATE:
			ai_investigatin_behavior.update_behavior(delta)
		behaviors_list.CHASE:
			pass
	
	current_speed = velocity.length()
	if not is_on_floor():
		velocity.y -= 10.0

func _process(delta: float) -> void:
	debug()
#endregion

#region CONTROLLERS
func animation_controller(delta:float):
	animation_player.set("parameters/movement/movement_offset/blend_position", velocity.length())
	
func movement_controller(delta):
	if can_move:
		if navigation_agent.is_navigation_finished():
			pass
		
		var next_target = navigation_agent.get_next_path_position()
		var new_next_target = Vector3(next_target.x, 0, next_target.z)
		var direction = (new_next_target - global_position).normalized()
		var target_rotation = atan2(direction.x, direction.z)
		
		velocity = direction * walk_speed
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
		
		movement_target = new_next_target

		move_and_slide()
	else:
		velocity = Vector3.ZERO
#endregion

#region CALLS
func change_behavior(value:behaviors_list) -> void:
	match value:
		behaviors_list.INVESTIGATE:
			is_investigation = true
			navigation_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL
		_:
			navigation_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_NONE
			
	current_behaviors_list = value
	
func debug():
	ImGui.Begin("%s" % name)
	#ImGui.Text("velocity: %s" % velocity.length())
	ImGui.Text("current_behavior: %s" % current_behaviors_list)
	if ImGui.TreeNode("Actor Flags"):
		if ImGui.Button("can_move: %s" % can_move):
			can_move = !can_move
		
		if ImGui.Button("can_see_actors: %s" % can_see_actors):
			can_see_actors = !can_see_actors
		
		if ImGui.Button("can_listen: %s" % can_listen):
			can_listen = !can_listen
		ImGui.TreePop()
	
	if can_see_actors and ImGui.TreeNode("Xenomorph Vision System"):
		ImGui.Text("seeing_player: %s" % vision_system.seeing_player)
		ImGui.Text("is_player_visible: %s" % vision_system.is_player_visible)
		ImGui.Text("focused_detecting: %s" % vision_system.focused_detecting)
		ImGui.Text("normal_detecting: %s" % vision_system.normal_detecting)
		ImGui.Text("peripheral_detecting: %s" % vision_system.peripheral_detecting)
		ImGui.TreePop()
	ImGui.End()
#endregion
