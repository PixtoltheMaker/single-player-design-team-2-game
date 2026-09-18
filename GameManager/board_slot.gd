class_name BoardSlot
extends Panel

signal slot_clicked(slot: BoardSlot)

@export var slot_index: int = 0

var card = null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				slot_clicked.emit(self)
