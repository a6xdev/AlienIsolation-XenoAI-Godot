extends Area3D
class_name MapRoomSystem

@export var room_name:String = "Room"

var room_marker := Marker3D.new()

var activity_level:float = 0.0
var activity_decay_rate: float = 0.01

var has_player:bool = false
var is_clear_for_ai:bool = false

func _ready() -> void:
	add_child(room_marker)
	name = room_name
	activity_level = 0.0
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, true)
	
	MapManager.add_place(self)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_boddy_exited)


func _process(delta: float) -> void:
	debug()

func debug():
	ImGui.Begin("RoomSystem")
	ImGui.Text("activity_level: %s" % activity_level)
	ImGui.End()

func _on_body_entered(body):
	if body is Player:
		MapManager.player_current_room = self
		activity_level += 0.5
		has_player = true
		
	if body is ActorXenomorph:
		MapManager.enemy_current_room = self
	
func _on_boddy_exited(body):
	if body is Player:
		activity_level -= 0.5
		has_player = false
