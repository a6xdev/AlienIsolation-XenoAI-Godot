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

func update_system(delta:float):
	if not player_ref:
		return
	
	var modifier:float = 0.0
	if focused_detecting: modifier += 4.0
	if normal_detecting: modifier += 2.0
	if peripheral_detecting: modifier += 0.5
	if player_ref.is_crouching: modifier *= 0.5
	# if player is in light
	
	if modifier > 0.0: 
		seeing_player = clamp(seeing_player + modifier * delta, 0.0, SEE_THRESHOLD)
	else:
		seeing_player = clamp(seeing_player - 2.0 * delta, 0.0, SEE_THRESHOLD)
	
	if seeing_player >= SEE_THRESHOLD and not is_player_visible:
		is_player_visible = true
	elif seeing_player <= 0.0 and is_player_visible:
		is_player_visible = false

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
