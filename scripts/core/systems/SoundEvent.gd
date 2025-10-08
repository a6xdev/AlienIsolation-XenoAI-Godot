extends Area3D
class_name SoundEvent

var mesh := MeshInstance3D.new()
var mesh_shape := BoxMesh.new()
var collision_shape := CollisionShape3D.new()
var shape := SphereShape3D.new()

var expand_speed: float = 20.0
var max_distance:float = 10.0

var current_radius:float = 0.0

func _ready() -> void:
	#add_child(mesh)
	add_child(collision_shape)
	
	mesh.mesh = mesh_shape
	
	collision_shape.shape = shape
	shape.radius = 0.1

func _process(delta: float) -> void:
	current_radius += expand_speed * delta
	shape.radius = current_radius

	if current_radius >= max_distance:
		queue_free()
