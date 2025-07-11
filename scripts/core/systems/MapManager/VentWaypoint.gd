extends Marker3D
class_name VentWaypoint

func _ready() -> void:
	MapManager.vents.append(self)
