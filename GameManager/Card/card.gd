class_name GameCard
extends Control

signal card_clicked(card: GameCard)

@export var data: CardData

var owner_id: int = 0
var board_position: Vector2i = Vector2i(-1, -1)


@onready var artwork: TextureRect = $Artwork
@onready var up_value: Label = $UpValue
@onready var right_value: Label = $RightValue
@onready var down_value: Label = $DownValue
@onready var left_value: Label = $LeftValue
@onready var name_label: Label = $NameLabel


func _ready() -> void:
	update_card()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				card_clicked.emit(self)


func update_card() -> void:
	if data == null:
		return
	name_label.text = data.card_name
	up_value.text = str(data.up)
	right_value.text = str(data.right)
	down_value.text = str(data.down)
	left_value.text = str(data.left)
	artwork.texture = data.artwork


func set_card_owner(new_owner: int) -> void:
	owner_id = new_owner
	update_owner_visual()


func update_owner_visual() -> void:
	if owner_id == 0:
		modulate = Color(0.7, 0.8, 1.0)
	else:
		modulate = Color(1.0, 0.7, 0.7)













#
