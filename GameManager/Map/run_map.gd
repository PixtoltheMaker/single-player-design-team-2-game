extends Control


@export var room_scene: PackedScene

const COLUMNS := 7
const ROWS := 3

var map_rooms: Array[RoomData] = []


func _ready() -> void:
	generate_map()
	create_map_visuals()


func get_random_room_type() -> RoomData.RoomType:
	var possible_rooms = [
		RoomData.RoomType.COMBAT,
		RoomData.RoomType.COMBAT,
		RoomData.RoomType.COMBAT,
		RoomData.RoomType.ELITE,
		RoomData.RoomType.HEALING,
		RoomData.RoomType.CARD,
		RoomData.RoomType.CARD,
		RoomData.RoomType.ITEM,
		RoomData.RoomType.BUFF,
		RoomData.RoomType.RANDOM,
		RoomData.RoomType.RANDOM,
		RoomData.RoomType.RANDOM,
		RoomData.RoomType.RANDOM,
		RoomData.RoomType.RANDOM
	]

	return possible_rooms.pick_random()


func generate_map() -> void:
	map_rooms.clear()
	# Generate normal columns.
	for column in range(COLUMNS - 1):
		for row in range(ROWS):
			var room := RoomData.new()
			room.column = column
			room.row = row
			room.room_type = get_room_type_for_column(column)
			map_rooms.append(room)
	var boss := RoomData.new()
	boss.column = COLUMNS - 1
	boss.row = 1
	boss.room_type = RoomData.RoomType.BOSS
	map_rooms.append(boss)


func get_room_type_for_column(column: int) -> RoomData.RoomType:
	if column == 0:
		var starting_rooms = [
			RoomData.RoomType.COMBAT,
			RoomData.RoomType.CARD,
			RoomData.RoomType.ITEM,
			RoomData.RoomType.BUFF
		]
		return starting_rooms.pick_random()
	return get_random_room_type()


func create_connections() -> void:
	for room in map_rooms:

		if room.room_type == RoomData.RoomType.BOSS:
			continue
		var next_rooms := get_rooms_in_column(room.column + 1)
		if next_rooms.is_empty():
			continue
		var closest_room: RoomData = next_rooms[0]
		var closest_distance := abs(
			room.row - closest_room.row
		)
		for target in next_rooms:
			var distance := abs(
				room.row - target.row
			)
			if distance < closest_distance:
				closest_room = target
				closest_distance = distance
		room.connections.append(closest_room)


func get_rooms_in_column(column: int) -> Array[RoomData]:
	var results: Array[RoomData] = []
	for room in map_rooms:
		if room.column == column:
			results.append(room)


func create_connections() -> void:
	for room in map_rooms:
		if room.room_type == RoomData.RoomType.BOSS:
			continue
		var next_rooms := get_rooms_in_column(
			room.column + 1
		)
		if next_rooms.is_empty():
			continue
		var valid_targets: Array[RoomData] = []
		for target in next_rooms:
			if abs(target.row - room.row) <= 1:
				valid_targets.append(target)
		if valid_targets.is_empty():
			continue
		var first_target: RoomData = valid_targets.pick_random()
		room.connections.append(first_target)
		# 40% chance for a second path.
		if valid_targets.size() > 1 and randf() < 0.40:
			var second_target: RoomData = valid_targets.pick_random()
			while second_target == first_target:
				second_target = valid_targets.pick_random()
			room.connections.append(second_target)




























#
