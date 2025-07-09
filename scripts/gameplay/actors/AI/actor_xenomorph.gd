extends CharacterBody3D
class_name ActorXenomorph

@onready var animation_player: AnimationPlayer = $model/AnimationPlayer
@onready var animation_tree: AnimationTree = $model/AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent

var move_dir:Vector3 = Vector3.ZERO

@export_group("Actor Settings")
@export var can_move:bool = true
@export var can_see_actors:bool = false
@export var can_listen:bool = false

@export_subgroup("Speed Settings")
@export var walk_speed:float = 2.0
@export var run_speed:float = 5.0
@export var rotation_speed:int = 6
var accel_speed:float = 30.0

var current_speed:float = 0.0
var current_speed_anim:float = 0.0
var target_speed:float = 0.0

var is_inspect:bool = false
var is_idle_searching:bool = false
var is_with_fear:bool = false
var is_crawling:bool = false

# Movement
var movement_target:Vector3

#region GODOT FUNCTIONS
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if can_move: movement_controller(delta)
	animation_controller(delta)
	
	current_speed = velocity.length()

func _process(delta: float) -> void:
	debug()
#endregion

#region CONTROLLERS
func animation_controller(delta:float):
	pass
	
func movement_controller(delta):
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
#endregion

#region CALLS
func debug():
	pass
#endregion
