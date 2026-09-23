class_name MapRoom
extends Button


signal room_selected(room: MapRoom)

var data: RoomData


func setup(room_data: RoomData) -> void:
	data = room_data
	match data.room_type:
		RoomData.RoomType.COMBAT:
			text = "⚔"
		RoomData.RoomType.ELITE:
			text = "☠"
		RoomData.RoomType.HEALING:
			text = "♥"
		RoomData.RoomType.CARD:
			text = "CARD"
		RoomData.RoomType.ITEM:
			text = "ITEM"
		RoomData.RoomType.BUFF:
			text = "BUFF"
		RoomData.RoomType.RANDOM:
			text = "?"
		RoomData.RoomType.BOSS:
			text = "BOSS"
	disabled = not data.available


func _pressed() -> void:
	if data.available:
		room_selected.emit(self)
