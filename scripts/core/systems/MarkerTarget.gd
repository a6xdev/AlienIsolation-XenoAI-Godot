extends Marker3D
class_name MarkerTarget

func _ready() -> void:
	top_level = true
	
	var mesh = CSGSphere3D.new()
	mesh.scale = Vector3(0.1, 0.1, 0.1)
	add_child(mesh)
	
	var shape = CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = 1.0
	add_child(shape)
