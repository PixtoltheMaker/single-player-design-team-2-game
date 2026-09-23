extends Control

@export var room_scene: PackedScene

const COLUMNS := 7
const ROWS := 3

@onready var rooms_container: Control = $MapPanel/Rooms
@onready var connection_lines: MapConnections = $MapPanel/ConnectionLines

var room_nodes: Dictionary = {}
var map_rooms: Array[RoomData] = []


func _ready() -> void:
	generate_map()
	create_connections()
	connect_to_boss()
	unlock_starting_rooms()
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



func get_rooms_in_column(column: int) -> Array[RoomData]:
	var results: Array[RoomData] = []
	for room in map_rooms:
		if room.column == column:
			results.append(room)
	return results


func connect_to_boss() -> void:
	var boss: RoomData = null
	for room in map_rooms:
		if room.room_type == RoomData.RoomType.BOSS:
			boss = room
			break
	if boss == null:
		return
	var previous_column := COLUMNS - 2
	for room in map_rooms:
		if room.column == previous_column:
			room.connections.clear()
			room.connections.append(boss)


func create_map_visuals() -> void:
	room_nodes.clear()
	for child in rooms_container.get_children():
		child.queue_free()
	for room_data in map_rooms:
		var room_node: MapRoom = room_scene.instantiate()
		rooms_container.add_child(room_node)
		room_node.setup(room_data)
		room_node.position = get_room_position(room_data)
		room_node.room_selected.connect(_on_room_selected)
		room_nodes[room_data] = room_node
	connection_lines.setup(map_rooms, room_nodes)


func unlock_starting_rooms() -> void:
	for room in map_rooms:
		if room.column == 0:
			room.available = true


func _on_room_selected(room: MapRoom) -> void:
	var room_data := room.data
	print("Entering ", RoomData.RoomType.keys()[room_data.room_type])
	enter_room(room_data)


func enter_room(room: RoomData) -> void:
	match room.room_type:
		RoomData.RoomType.COMBAT:
			start_combat("normal")
		RoomData.RoomType.ELITE:
			start_combat("elite")
		RoomData.RoomType.HEALING:
			open_healing_room()
		RoomData.RoomType.CARD:
			open_card_room()
		RoomData.RoomType.ITEM:
			open_item_room()
		RoomData.RoomType.BUFF:
			open_buff_room()
		RoomData.RoomType.RANDOM:
			open_random_room()
		RoomData.RoomType.BOSS:
			start_combat("boss")


func open_random_room() -> void:
	var events: Array[String] = ["combat", "heal", "card", "item", "buff"]
	var event: String = events.pick_random()
	match event:
		"combat":
			start_combat("normal")
		"heal":
			open_healing_room()
		"card":
			open_card_room()
		"item":
			open_item_room()
		"buff":
			open_buff_room()


func complete_room(room: RoomData) -> void:
	room.completed = true
	room.available = false
	for map_room in map_rooms:
		map_room.available = false
	for connected_room in room.connections:
		connected_room.available = true
	refresh_map()


func get_room_position(room: RoomData) -> Vector2:
	const START_X := 60.0
	const START_Y := 70.0
	const COLUMN_SPACING := 200.0
	const ROW_SPACING := 170.0
	var x := (START_X + room.column * COLUMN_SPACING)
	var y := (START_Y + room.row * ROW_SPACING)
	return Vector2(x, y)


func start_combat(combat_type: String) -> void:
	print("Starting combat: ", combat_type)
	match combat_type:
		"normal":
			print("Normal Combat")
		"elite":
			print("Elite Combat")
		"boss":
			print("Boss Combat")


func open_healing_room() -> void:
	print("Opening Healing Room")


func open_card_room() -> void:
	print("Opening Card Room")


func open_item_room() -> void:
	print("Opening Item Room")


func open_buff_room() -> void:
	print("Opening Buff Room")


func refresh_map() -> void:
	for room_data in map_rooms:
		if room_nodes.has(room_data):
			var room_node: MapRoom = room_nodes[room_data]
			room_node.update_visual()
	connection_lines.queue_redraw()











#
