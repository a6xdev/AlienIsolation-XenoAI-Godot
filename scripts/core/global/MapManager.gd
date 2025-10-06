extends Node

var map_rooms:Array[MapRoomSystem] = []
var map_vent_points:Array[VentPoint] = []

var activity_places:Array = []
var viable_room_nearby:Array = []
var viable_distant:Array = []
var recently_visited:Array = []
var perfect_room_index:int = 0

var player_current_room:MapRoomSystem = null
var xeno_current_room:MapRoomSystem = null
var xeno_current_vent:VentPoint = null

#region GODOT FUNCTIONS
func _process(delta: float) -> void:
	for room in map_rooms:
		if room.activity_level >= 0.5:
			activity_places.append(room)
		else:
			if activity_places.has(room):
				activity_places.erase(room)
#endregion

#region CALLS
func add_room_database(room:MapRoomSystem) -> void:
	map_rooms.append(room)
func remove_room_database(room:MapRoomSystem) -> void:
	map_rooms.erase(room)

func add_vent_point_database(vent:VentPoint) -> void:
	map_vent_points.append(vent)
func remove_vent_database(vent:VentPoint) -> void:
	map_vent_points.erase(vent)

func get_random_room() -> MapRoomSystem:
	return map_rooms.pick_random() if not map_rooms.is_empty() else null

func get_perfect_room(ai_position:Vector3) -> MapRoomSystem:
	var min_score = 0.3
	
	viable_room_nearby.clear()
	viable_distant.clear()
	perfect_room_index += 1
	
	for room in activity_places:
		if not room:
			return get_random_room()
			
		if room == xeno_current_room:
			# TODO: logic to explore the place.
			return get_random_room()
			
		var distance = ai_position.distance_to(room.global_position)
		var distance_factor = 1.0 - clamp(distance / 60.0, 0.0, 1.0)
		var score = room.activity_level * 0.6 + distance_factor * 0.4 + randf() * 0.1
		
		if score >= min_score and not recently_visited.has(room):
			viable_room_nearby.append({"room": room, "score": score})
		else:
			viable_distant.append({"room": room, "score": score})

	viable_room_nearby.sort_custom(func(a, b): return a["score"] > b["score"])
	if viable_room_nearby.size() >= 2 and randf() < 0.45:
		return viable_room_nearby[1]["room"]
	elif viable_distant.size() > 0:
		viable_distant.shuffle()
		return viable_distant[0]["room"]
	else:
		return get_random_room()

func get_random_duct() -> VentPoint:
	var vent = map_vent_points.pick_random()
	while vent == xeno_current_vent:
		vent = map_vent_points.pick_random()
	return vent

func get_perfect_duct(ai_position:Vector3) -> VentPoint:
	var closest_vent:VentPoint = null
	var shortest_distantce = INF
	
	for vent in map_vent_points:
		var distance = ai_position.distance_to(vent.global_position)
		if distance < shortest_distantce:
			shortest_distantce = distance
			closest_vent = vent
	
	xeno_current_vent = closest_vent
	return closest_vent
#endregion
