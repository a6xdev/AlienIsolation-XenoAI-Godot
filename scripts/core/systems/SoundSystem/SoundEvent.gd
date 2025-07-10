extends Area3D
class_name SoundEvent

@onready var collision_shape: CollisionShape3D = $collision

var expand_speed: float = 20.0
var max_distance:float = 10.0

var current_radius:float = 0.0

func _ready() -> void:
	var original_shape = collision_shape.shape
	collision_shape.shape = original_shape.duplicate()
	
	var shape := collision_shape.shape as SphereShape3D
	shape.radius = 0.1

func _process(delta: float) -> void:
	var shape := collision_shape.shape as SphereShape3D
	current_radius += expand_speed * delta
	shape.radius = current_radius

	if current_radius >= max_distance:
		queue_free()
