extends CharacterBody3D
class_name Player

@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/camera
@onready var collision: CollisionShape3D = $collision
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var top_cast: RayCast3D = $TopCast

@onready var footstep_sound: AudioStreamPlayer3D = $sounds/footstep_sound

var look_rot = Vector3.ZERO
var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

@export_category("Player")
@export var can_move:bool = true
@export var can_move_cam:bool = true
@export var can_lean:bool = true

@export_group("Settings")
@export var p_walkink_speed:float = 1.0
@export var p_running_speed:float = 3.0
@export var p_crounched_speed:float = 0.5

var current_speed:float = 1.0

var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var is_crouched:bool = false
var is_crouched_to_hide:bool = false
var is_leaning:bool = false

var cam_max_angle = 90
var cam_min_angle = -80

var footstep_timer = 0.0
var footstep_interval = 0.55

#region GODOT FUNCTIONS
func _ready() -> void:
	Global.player_ref = self

func _input(event: InputEvent) -> void:
	if can_move_cam and not Global.cursor_visible:
		if event is InputEventMouseMotion:
			look_rot.y -= (event.relative.x * GameSettings.m_sensitivity)
			look_rot.x -= (event.relative.y * GameSettings.m_sensitivity)
			look_rot.x = clamp(look_rot.x, cam_min_angle, cam_max_angle)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	animation_controller()
	camera_controller()
	movement_controller(delta)
	sound_controller(delta)
	
	lean_mechanic(delta)
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
#endregion

#region CONTROLLERS
func animation_controller() -> void:
	if velocity.length() < 0.5:
		is_stopped = true
		is_walking = false
		is_running = false
	else:
		is_stopped = false
		if is_running:
			is_walking = false
		else:
			is_walking = true
		
func camera_controller() -> void:
	var joy_axis_x = Input.get_action_strength("JOY_ANALOG_X_POSITIVE") - Input.get_action_strength("JOY_ANALOG_X_NEGATIVE")
	var joy_axis_y = Input.get_action_strength("JOY_ANALOG_Y_POSITIVE") - Input.get_action_strength("JOY_ANALOG_Y_NEGATIVE")
	
	if can_move_cam:
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y
		
		if joy_axis_x != 0:
			look_rot.y -= joy_axis_x * GameSettings.c_sensitivity
		if joy_axis_y != 0:
			look_rot.x -= joy_axis_y * GameSettings.c_sensitivity
		look_rot.x = clamp(look_rot.x, cam_min_angle, cam_max_angle)

func movement_controller(_delta:float) -> void:
	if can_move and not is_leaning:
		move_dir = Vector3(
			Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
			0.0,
			Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
		).normalized().rotated(Vector3.UP, rotation.y)
		
		if Input.is_action_pressed("m_run") and not is_crouched:
			current_speed = p_running_speed
			is_running = true
		elif is_crouched:
			current_speed = p_crounched_speed
			is_running = false
		else:
			current_speed = p_walkink_speed
			is_running = false
		
		if Input.is_action_just_pressed("m_crouch"):
			if top_cast.is_colliding() and is_crouched:
				return
			
			is_crouched = !is_crouched
		
		velocity.x = lerp(velocity.x, move_dir.x * current_speed, 30.0 * _delta)
		velocity.z = lerp(velocity.z, move_dir.z * current_speed, 30.0 * _delta)
			
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func sound_controller(_delta:float):
	footstep_timer += _delta
	
	if not is_stopped and is_on_floor():
		if footstep_timer >= footstep_interval and velocity.length() > 0.1:
			if is_crouched:
				footstep_interval = 0.75
				footstep_sound.play()
				footstep_sound.volume_db = -5.0
			else:
				var sound_event := SoundEvent.new()
				add_child(sound_event)
				
				if is_running:
					footstep_interval = 0.4
					footstep_sound.play()
					footstep_sound.volume_db = 0.0
					sound_event.max_distance = 15.0
					sound_event.global_position = global_position
				elif is_walking:
					footstep_interval = 0.75
					footstep_sound.play()
					footstep_sound.volume_db = -15.0
					sound_event.max_distance = 5.0
					sound_event.global_position = global_position
			
			footstep_timer = 0.0
			
#endregion

#region MECHANICS
func lean_mechanic(_delta):
	if Input.is_action_pressed("a_lean") and can_lean:
		is_leaning = true
		if Input.is_action_pressed("m_left"):
			self.rotation.z = lerp(self.rotation.z, 0.5, 10 * _delta)
		elif Input.is_action_pressed("m_right"):
			self.rotation.z = lerp(self.rotation.z, -0.5, 10 * _delta)
		else:
			self.rotation.z = lerp(self.rotation.z, 0.0, 10 * _delta)
	else:
		is_leaning = false
		self.rotation.z = lerp(self.rotation.z, 0.0, 10 * _delta)
#endregion

#region CALLS
#endregion

#region SIGNALS
#endregion
