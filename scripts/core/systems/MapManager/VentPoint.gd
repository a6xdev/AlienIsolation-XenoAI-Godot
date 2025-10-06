extends Marker3D
class_name VentPoint

func _ready() -> void:
	MapManager.add_vent_point_database(self)
