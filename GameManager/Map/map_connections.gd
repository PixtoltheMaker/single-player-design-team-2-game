class_name MapConnections
extends Control

var map_rooms: Array[RoomData] = []
var room_nodes: Dictionary = {}


func setup(rooms: Array[RoomData], nodes: Dictionary) -> void:
	map_rooms = rooms
	room_nodes = nodes
	queue_redraw()


func _draw() -> void:
	if map_rooms.is_empty():
		return
	for room_data in map_rooms:
		if not room_nodes.has(room_data):
			continue
		var start_node: Control = room_nodes[room_data]
		for target_data in room_data.connections:
			if not room_nodes.has(target_data):
				continue
			var target_node: Control = room_nodes[target_data]
			var start_position := (start_node.position + start_node.size / 2.0)
			var end_position := (target_node.position + target_node.size / 2.0)
			var line_color := get_connection_color(room_data, target_data)
			draw_dashed_line(start_position, end_position, line_color, 5.0, 12.0, true)


func get_connection_color(from_room: RoomData, to_room: RoomData) -> Color:
	if from_room.completed:
		if to_room.available:
			return Color(1.0, 0.85, 0.3)
		return Color(0.45, 0.45, 0.45)
	return Color(0.25, 0.25, 0.25)





































































#
