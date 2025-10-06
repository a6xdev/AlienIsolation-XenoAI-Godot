extends CharacterBody3D
class_name Xenomorph

@onready var mesh: Node3D = $mesh
@onready var collision: CollisionShape3D = $collision
@onready var animation_tree: AnimationTree = $mesh/AnimationTree
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $mesh/xenomorph_main/Skeleton3D/PhysicalBoneSimulator3D
@onready var vision_system: Node = $systems/VisionSystem
@onready var agent: NavigationAgent3D = $agent
@onready var attack_area: Area3D = $areas/AttackArea
@onready var attack_camera_3d: Camera3D = $mesh/xenomorph_main/Skeleton3D/AttackCamera/AttackCamera3D

@onready var sounds: Node3D = $sounds
@onready var vent_climb_out: AudioStreamPlayer3D = $sounds/VentClimbOut

@onready var ai_patrol: Node = $behaviors/AI_PATROL
@onready var ai_investigate: Node = $behaviors/AI_INVESTIGATE
@onready var ai_chase: Node = $behaviors/AI_CHASE
@onready var ai_vent: Node = $behaviors/AI_VENT

@onready var pb_tail_01: PhysicalBone3D = $"mesh/xenomorph_main/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone tail 1"
@onready var pb_tail_02: PhysicalBone3D = $"mesh/xenomorph_main/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone tail 2"
@onready var pb_tail_03: PhysicalBone3D = $"mesh/xenomorph_main/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone tail 3"

enum State {
	PATROL,
	INVESTIGATE,
	CHASE,
	VENT
}

var move_dir = Vector3.ZERO
var look_rot:float = 0.0

@export var ai_can_move:bool = true
@export var ai_can_see:bool = true

@export_group("Settings")
@export var ai_walking_speed:float = 2.0
@export var ai_running_speed:float = 7.0

var current_state:State = State.PATROL
var current_speed:float = 0.0
var duct_current_target:VentPoint = null

var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var is_inspecting:bool = false
var is_attacking:bool = false
var is_being_seen:bool = false
var is_on_duct:bool = false

var attack_index:int = 1

signal KillPlayer;

#region GODOT FUNCTIONS
func _ready() -> void:
	Global.xenomorph_ref = self
	
	await get_tree().create_timer(5.0)
	
	ai_patrol.start_behavior()
	
	physical_bone_simulator.physical_bones_start_simulation()
	physical_bone_simulator.set_translation_domain("Physical Bone tail 1")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("any_key_02"):
		ai_investigate.set_place_to_investigate(Global.player_ref.global_position)
	
	var t:float = 0.0
	
	match current_state:
		State.PATROL:
			ai_patrol.update_behavior(delta)
			current_speed = ai_walking_speed
			attack_area.monitoring = false
		State.INVESTIGATE:
			ai_investigate.update_behavior(delta)
			current_speed = ai_walking_speed + 1.0
			attack_area.monitoring = false
		State.CHASE:
			ai_chase.update_behavior(delta)
			current_speed = ai_running_speed
			attack_area.monitoring = true
		State.VENT:
			ai_vent.update_behavior(delta)
			current_speed = ai_walking_speed
			attack_area.monitoring = false
	
func _physics_process(delta: float) -> void:
	animation_controller()
	if not is_on_duct: movement_controller(delta)
	if is_on_duct: duct_movement_controller(delta)
	
	pb_tail_01.linear_velocity = velocity
	#pb_tail_01.angular_velocity = -move_dir
	
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
		
		match current_state:
			State.PATROL:
				is_walking = true
				is_running = false
			State.INVESTIGATE:
				is_walking = true
				is_running = false
			State.CHASE:
				is_walking = false
				is_running = true
			State.VENT:
				is_walking = true
				is_running = false

func movement_controller(_delta:float):
	if ai_can_move:
		if agent.is_navigation_finished():
			pass
		
		var target = agent.get_next_path_position()
		move_dir = (target - global_position).normalized()
		look_rot = atan2(move_dir.x, move_dir.z)
		
		velocity = move_dir * current_speed
		rotation.y = lerp_angle(rotation.y, look_rot, 5.0 * _delta)
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func duct_movement_controller(_delta:float):
	if duct_current_target:
		var dist = global_position.distance_to(duct_current_target.global_position)
		
		if dist < 0.5:
			mesh.show()
			collision.disabled = false
			ai_vent.is_leaving_to_duct = true
			is_on_duct = false
			return
		
		move_dir = (duct_current_target.global_position - global_position).normalized()
		global_position += move_dir * ai_walking_speed * _delta
#endregion

#region CALLS
func set_xeno_state(state:State) -> void:
	current_state = state

func attack() -> void:
	sounds.voice_over.stop()
	
	is_attacking = true
	ai_can_move = false
	ai_can_see = false
	
	Global.player_ref.global_rotation = lerp(Global.player_ref.global_rotation, Global.xenomorph_ref.attack_camera_3d.global_rotation, 1.0)
	
	physical_bone_simulator.physical_bones_stop_simulation()

func emit_kill_player() -> void:
	KillPlayer.emit()
#endregion

#region SIGNALS
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"vent_climb_in":
			mesh.hide()
			collision.disabled = true
			duct_current_target = MapManager.get_random_duct()
		"vent_climb_out":
			physical_bone_simulator.physical_bones_start_simulation()
			duct_current_target = null
			ai_vent.reset_vent_behavior()
			ai_patrol.set_random_target()
			set_xeno_state(State.PATROL)

func _on_vision_system_actor_spotted(body: Player) -> void:
	set_xeno_state(State.CHASE)

func _on_vision_system_actor_lost() -> void:
	ai_chase.reset_behavior()
	set_xeno_state(State.PATROL)

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Player:
		attack()
		
func _on_visible_on_screen_notifier_screen_entered() -> void:
	is_being_seen = true
func _on_visible_on_screen_notifier_screen_exited() -> void:
	is_being_seen = false
#endregion
