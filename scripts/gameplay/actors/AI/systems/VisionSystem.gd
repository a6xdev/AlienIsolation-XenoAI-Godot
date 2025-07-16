extends Node

@onready var vision_focused: VisionCone3D = $"../../model/xenomorph_main/Skeleton3D/Head/VisionFocused"
@onready var vision_normal: VisionCone3D = $"../../model/xenomorph_main/Skeleton3D/Head/VisionNormal"
@onready var vision_peripheral: VisionCone3D = $"../../model/xenomorph_main/Skeleton3D/Head/VisionPeripheral"

@export var actor:ActorXenomorph

const SEE_THRESHOLD:float = 5.0

var player_ref:Player
var seeing_player:float = 0.0
var timer_lose_sight_of_player: float = 0.0

var is_player_visible:bool = false
var maybe_is_seing_player:bool = false
var focused_detecting:bool = false
var normal_detecting:bool = false
var peripheral_detecting:bool = false

signal actor_spotted(body:Player)
signal actor_lost()

func update_system(delta:float):
	if not player_ref:
		return
	
	var modifier:float = 0.0
	# Here you can adjust the values to your liking. You can make the AI more difficult or easier by balancing these numbers.
	if focused_detecting: modifier += 5.0
	if normal_detecting: modifier += 3.0
	if peripheral_detecting: modifier += 1.5
	if player_ref.is_crouching: modifier *= 0.5
	# TODO: player_ref.is_in_light
	
	if modifier > 0.0: 
		seeing_player = clamp(seeing_player + modifier * delta, 0.0, SEE_THRESHOLD)
	else:
		seeing_player = clamp(seeing_player - 2.0 * delta, 0.0, SEE_THRESHOLD)
	
	if seeing_player >= SEE_THRESHOLD and not is_player_visible:
		is_player_visible = true
		emit_signal("actor_spotted", player_ref)
	elif seeing_player <= 0.0 and is_player_visible:
		await get_tree().create_timer(2.0).timeout
		is_player_visible = false
		player_ref = null
		actor_lost.emit()

func change_vision_debug_draw(value:bool):
	vision_focused.debug_draw = value
	vision_normal.debug_draw = value
	vision_peripheral.debug_draw = value

#region SIGNALS
func _on_vision_focused_body_sighted(body: Node3D) -> void:
	if body is Player:
		focused_detecting = true
		player_ref = body
func _on_vision_focused_body_hidden(body: Node3D) -> void:
	if body is Player:
		focused_detecting = false

func _on_vision_normal_body_sighted(body: Node3D) -> void:
	if body is Player:
		normal_detecting = true
		player_ref = body
func _on_vision_normal_body_hidden(body: Node3D) -> void:
	if body is Player:
		normal_detecting = false

func _on_vision_peripheral_body_sighted(body: Node3D) -> void:
	if body is Player:
		peripheral_detecting = true
		player_ref = body
func _on_vision_peripheral_body_hidden(body: Node3D) -> void:
	if body is Player:
		peripheral_detecting = false
#endregion
