extends CharacterBody3D
class_name Player

@onready var head: Node3D = $head

enum STATE {
	IDLE,
	WALKING,
	RUNNING
}

var look_rot = Vector3.ZERO
var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

var current_player_state:STATE = STATE.IDLE

@export var can_move_head:bool = true
@export var can_move:bool = true
@export var can_run:bool = true
@export var can_interact:bool = true

@export_group("Player Settings")
@export_subgroup("Sensitivity")
@export var mouse_sensitivity:float = 0.2
@export var joystick_sensitivity:float = 2.0
@export_subgroup("Speeds")
@export var accel_speed:float = 30.0
@export var walk_speed:float = 0.7
@export var run_speed:float = 2.0

var cam_max_angle = 90
var cam_min_angle = -80

var footstep_timer = 0.0
var footstep_interval = 0.55

var in_debug:bool = false
var run_toggle:bool = false
var is_moving:bool = false
var is_running:bool = false
var in_interface:bool = false

#region GODOT FUNCTIONS
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if can_move_head and not in_debug:
		if event is InputEventMouseMotion:
			look_rot.y -= (event.relative.x * mouse_sensitivity)
			look_rot.x -= (event.relative.y * mouse_sensitivity)
			look_rot.x = clamp(look_rot.x, cam_min_angle, cam_max_angle)
	
	if Input.is_action_just_pressed("a_debug"):
		in_debug = !in_debug
	
	if Input.is_action_just_pressed("m_run"):
		run_toggle = !run_toggle

func _process(delta: float) -> void:
	if in_debug:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not in_debug:
		# Controllers
		state_controller()
		#sound_controller(delta) if can_move else null
		camera_controller()
		movement_controller(delta)
#endregion

#region CONTROLLER
func state_controller() -> void:
	if velocity.length() > 0.5:
		if is_running:
			current_player_state = STATE.RUNNING
		else:
			if is_moving:
				current_player_state = STATE.WALKING
	else:
			current_player_state = STATE.IDLE
			is_running = false
			is_moving = false

func camera_controller() -> void:
	var joy_axis_x = Input.get_action_strength("JOY_ANALOG_X_POSITIVE") - Input.get_action_strength("JOY_ANALOG_X_NEGATIVE")
	var joy_axis_y = Input.get_action_strength("JOY_ANALOG_Y_POSITIVE") - Input.get_action_strength("JOY_ANALOG_Y_NEGATIVE")
	
	if can_move_head:
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y
		
		if joy_axis_x != 0:
			look_rot.y -= joy_axis_x * joystick_sensitivity
		if joy_axis_y != 0:
			look_rot.x -= joy_axis_y * joystick_sensitivity
		look_rot.x = clamp(look_rot.x, cam_min_angle, cam_max_angle)

func sound_controller(_delta:float):
	footstep_timer += _delta
	
	if current_player_state != STATE.IDLE and is_on_floor():
		if footstep_timer >= footstep_interval and velocity.length() > 0.1:
			match current_player_state:
				STATE.WALKING:
					$sounds/Footstep.play()
					footstep_interval = 0.55
				STATE.RUNNING:
					$sounds/Footstep.play()
					footstep_interval = 0.35
					
			footstep_timer = 0.0

func movement_controller(delta:float):
	if can_move:
		move_dir = Vector3(
			Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
			0.0,
			Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
		).normalized().rotated(Vector3.UP, rotation.y)
		
		if (Input.get_action_strength("m_run") && Input.get_action_strength("m_forward") && can_run) or (run_toggle and (run_toggle and Input.get_action_strength("m_forward") > 0.3 and can_run)):
			velocity.x = lerp(velocity.x, move_dir.x * run_speed, accel_speed * delta)
			velocity.z = lerp(velocity.z, move_dir.z * run_speed, accel_speed * delta)
			is_moving = true
			is_running = true
		else:
			velocity.x = lerp(velocity.x, move_dir.x * walk_speed, accel_speed * delta)
			velocity.z = lerp(velocity.z, move_dir.z * walk_speed, accel_speed * delta)
			is_moving = true
			is_running = false
			run_toggle = false
			
		move_and_slide()
		
		if not is_on_floor():
			velocity.y -= 9.8 * delta
#endregion

#region MECHANICS
#endregion

#region CALLS
#endregion

#region SIGNALS
#endregion
