extends Node

@onready var actor_xenomorph: Xenomorph = $"../.."

var seeing_player:float = 0.0
var seeing_player_ref:Player = null

var focused_detecting:bool = false
var normal_detecting:bool = false
var peripheral_detecting:bool = false

var is_player_visible:bool = false

signal actor_spotted(body:Player)
signal actor_lost()

func _process(delta: float) -> void:
	if actor_xenomorph.ai_can_see and not Global.player_ref.is_crouched_to_hide:
		var modifier:float = 0.0
		
		if focused_detecting: modifier += 7.0
		if normal_detecting: modifier += 4.0
		if peripheral_detecting: modifier += 1.5
		if Global.player_ref.is_crouched: modifier *= 0.4
		
		if modifier > 0.0:
			seeing_player = clamp(seeing_player + modifier * delta, 0.0, 5.0)
		else:
			seeing_player = clamp(seeing_player - 2.0 * delta, 0.0, 5.0)
		
		if seeing_player >= 5.0 and not is_player_visible:
			is_player_visible = true
			emit_signal("actor_spotted", seeing_player_ref)
		elif seeing_player <= 0.0 and is_player_visible:
			await get_tree().create_timer(2.0).timeout
			actor_lost.emit()
			is_player_visible = false

func reset_all() -> void:
	seeing_player = 0.0
	seeing_player_ref = null
	focused_detecting = false
	normal_detecting = false
	peripheral_detecting = false
	is_player_visible = false

#region SIGNALS
func _on_focused_vision_body_sighted(body: Node3D) -> void:
	if body is Player:
		focused_detecting = true
		seeing_player_ref = body
func _on_focused_vision_body_hidden(body: Node3D) -> void:
	if body is Player:
		focused_detecting = false
		seeing_player_ref = null

func _on_normal_vision_body_sighted(body: Node3D) -> void:
	if body is Player:
		normal_detecting = true
		seeing_player_ref = body
func _on_normal_vision_body_hidden(body: Node3D) -> void:
	if body is Player:
		normal_detecting = false
		seeing_player_ref = null

func _on_peripheral_vision_body_sighted(body: Node3D) -> void:
	if body is Player:
		peripheral_detecting = true
		seeing_player_ref = body
func _on_peripheral_vision_body_hidden(body: Node3D) -> void:
	if body is Player:
		peripheral_detecting = false
		seeing_player_ref = null
#endregion
