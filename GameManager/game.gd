extends Control

var board: Array = [
	null, null, null,
	null, null, null,
	null, null, null
]

@onready var board_container: GridContainer = $CenterContainer/Board


func _ready() -> void:
	for child in board_container.get_children():
		if child is BoardSlot:
			child.slot_clicked.connect(_on_slot_clicked)
		else:
			print("WARNING: ", child.name, " is not a BoardSlot!")


func _on_slot_clicked(slot: BoardSlot) -> void:
	print("Clicked slot: ", slot.slot_index)
