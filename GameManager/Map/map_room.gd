class_name MapRoom
extends Button


signal room_selected(room: MapRoom)

var data: RoomData


func setup(room_data: RoomData) -> void:
	data = room_data
	custom_minimum_size = Vector2(100, 100)
	size = custom_minimum_size
	update_visual()
	tooltip_text = get_room_description()


func update_visual() -> void:
	if data == null:
		return
	match data.room_type:
		RoomData.RoomType.COMBAT:
			text = "COMBAT"
		RoomData.RoomType.ELITE:
			text = "ELITE"
		RoomData.RoomType.HEALING:
			text = "HEAL"
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
			custom_minimum_size = Vector2(140, 140)
	size = custom_minimum_size
	if data.completed:
		modulate = Color(0.5, 0.5, 0.5)
		disabled = true
	elif data.available:
		modulate = Color.WHITE
		disabled = false
	else:
		modulate = Color(0.35, 0.35, 0.35)
		disabled = true


func get_room_description() -> String:
	if data == null:
		return "Unknown Room"
	match data.room_type:
		RoomData.RoomType.COMBAT:
			return "Normal Combat\nFight a standard card opponent."
		RoomData.RoomType.ELITE:
			return "Elite Combat\nFight a powerful opponent for better rewards."
		RoomData.RoomType.HEALING:
			return "Healing Room\nRecover health."
		RoomData.RoomType.CARD:
			return "Card Room\nChoose a new card."
		RoomData.RoomType.ITEM:
			return "Item Room\nGain a useful item."
		RoomData.RoomType.BUFF:
			return "Buff Room\nGain a one combat bonus."
		RoomData.RoomType.RANDOM:
			return "Unknown Room\nAnything could happen."
		RoomData.RoomType.BOSS:
			return "Boss\nDefeat the final opponent."
	return "Unknown Room"


func _pressed() -> void:
	if data == null:
		return
	if not data.available:
		return
	room_selected.emit(self)
