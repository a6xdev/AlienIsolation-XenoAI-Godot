extends Area3D
class_name MapRoomSystem

var activity_level:float = 0.0
var activity_decay_rate: float = 0.01

var has_player:bool = false
var has_xenomorph:bool = false
var is_clear_for_xeno:bool = false

var room_marker := Marker3D.new()

#region GODOT FUNCTIONS
func _ready() -> void:
	add_child(room_marker)
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)
	
	MapManager.add_room_database(self)
	
	body_entered.connect(_on_body_entered)
	body_entered.connect(_on_body_exited)

func _process(delta: float) -> void:
	if has_player: activity_level += 0.05 * delta
	else: activity_level -= activity_decay_rate * delta
		
	activity_level = clamp(activity_level, 0.0, 1.0)
#endregion

#region SIGNALS
func _on_body_entered(body:Node3D) -> void:
	if body is Player:
		MapManager.player_current_room = self
		has_player = true
	
	if body is Xenomorph:
		MapManager.xeno_current_room = self
		has_xenomorph = true

func _on_body_exited(body:Node3D) -> void:
	if body is Player:
		has_player = false
	
	if body is Xenomorph:
		has_xenomorph = false
#endregion
