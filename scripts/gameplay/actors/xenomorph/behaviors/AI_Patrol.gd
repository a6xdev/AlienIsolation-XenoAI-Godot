extends AIBehavior

@onready var actor_xenomorph: Xenomorph = $"../.."
@onready var sounds: Node3D = $"../../sounds"
@onready var vision_system: Node = $"../../systems/VisionSystem"

var current_patrol_target:MapRoomSystem = null

var old_target_index:int = -1
var target_index:int = 0

func start_behavior() -> void:
	set_random_target()

func update_behavior(_delta:float) -> void:
	if actor_xenomorph.agent.is_navigation_finished() and target_index != old_target_index:
		old_target_index = target_index
		
		if target_index >= 1 or (MapManager.player_current_room == MapManager.xeno_current_room):
			if actor_xenomorph.is_being_seen and not vision_system.seeing_player_ref: sounds.play_sound(sounds.SoundType.PATROL)
			await get_tree().create_timer(2.0).timeout
			target_index = 0
			actor_xenomorph.set_xeno_state(actor_xenomorph.State.VENT)
		else:
			if target_index == 3 and not vision_system.seeing_player_ref: 
				sounds.play_sound(sounds.SoundType.PATROL_AWAY_PLAYER)
			if actor_xenomorph.is_being_seen:
				await get_tree().create_timer(1.0).timeout
			
			current_patrol_target = MapManager.get_perfect_room(actor_xenomorph.global_position)
			var room_pos = Vector3(current_patrol_target.global_position.x, current_patrol_target.global_position.y + 1.0, current_patrol_target.global_position.z)
			actor_xenomorph.agent.set_target_position(room_pos)
		
		target_index += 1

func reset_behavior() -> void:
	target_index = 0

func set_random_target() -> void:
	current_patrol_target = MapManager.get_random_room()
	var room_pos = Vector3(current_patrol_target.global_position.x, current_patrol_target.global_position.y + 1.0, current_patrol_target.global_position.z)
	actor_xenomorph.agent.set_target_position(room_pos)
	target_index = 0
