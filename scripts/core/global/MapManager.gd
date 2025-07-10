extends Node

var last_room:MapRoomSystem
var player_current_room:MapRoomSystem
var enemy_current_room:MapRoomSystem

var rooms:Array[MapRoomSystem]
var activity_places:Array = []
var viable_room_nearby:Array = []
var viable_distant:Array = []
var recently_visited:Array = []
var perfect_room_index:int = 0

var nav_region:NavigationRegion3D

func _process(delta: float) -> void:
	for room in rooms:
		if room.activity_level >= 0.5:
			activity_places.append(room)

func add_place(room:MapRoomSystem):
	if not rooms.has(room):
		rooms.append(room)

func get_random_room() -> MapRoomSystem:
	var room = rooms[randi() % rooms.size()]
	return room

func get_perfect_room(ai_position:Vector3) -> MapRoomSystem:
	var min_score = 0.3
	
	viable_room_nearby.clear()
	viable_distant.clear()
	perfect_room_index += 1
	
	for room in activity_places:
		if room == enemy_current_room:
			# logic to explore the place.	
			Logger.print_msg(str("AI_IN_SAME_ROOM"))
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
		Logger.print_msg(str("PERFECT_ROOM_CHOSEN"))
		return viable_room_nearby[1]["room"]
	elif viable_distant.size() > 0:
		viable_distant.shuffle()
		Logger.print_msg(str("PERFECT_ROOM_CHOSEN_2"))
		return viable_distant[0]["room"]
	else:
		Logger.print_msg(str("GET ROOM RANDOM"))
		return get_random_room()
