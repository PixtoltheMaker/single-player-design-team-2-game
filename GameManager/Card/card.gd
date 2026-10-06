class_name GameCard
extends Control

signal card_clicked(card: GameCard)

@export var data: CardData

var owner_id: int = 0
var board_position: Vector2i = Vector2i(-1, -1)

@onready var card_background: Panel = $CardBackground
@onready var background: Panel = $Background
@onready var artwork: TextureRect = $Artwork
@onready var rarity_label: Label = $RarityLabel
@onready var up_value: Label = $UpValue
@onready var right_value: Label = $RightValue
@onready var down_value: Label = $DownValue
@onready var left_value: Label = $LeftValue
@onready var name_label: Label = $NameLabel
@onready var card_back: Panel = $CardBack
@onready var question_label: Label = $CardBack/QuestionLabel

var petrified: bool = false
var petrify_used: bool = false
var divine_shield_used: bool = false


func _ready() -> void:
	update_card()
	update_owner_visual()


func set_card_data(new_data: CardData) -> void:
	data = new_data
	update_card()


func update_card() -> void:
	if data == null:
		return
	name_label.text = data.card_name
	if data.artwork != null:
		artwork.texture = data.artwork
		artwork.visible = true
	else:
		artwork.texture = null
		artwork.visible = false
	up_value.text = str(data.up)
	right_value.text = str(data.right)
	down_value.text = str(data.down)
	left_value.text = str(data.left)
	update_rarity()


func update_rarity() -> void:
	if data == null:
		rarity_label.text = ""
		return
	match data.rarity:
		CardData.Rarity.NORMAL:
			rarity_label.text = "◆"
			rarity_label.modulate = Color(0.75, 0.75, 0.75)
		CardData.Rarity.RARE:
			rarity_label.text = "◆◆"
			rarity_label.modulate = Color(0.25, 0.55, 1.0)
		CardData.Rarity.MYTHIC:
			rarity_label.text = "◆◆◆"
			rarity_label.modulate = Color(0.8, 0.3, 1.0)
		_:
			rarity_label.text = "◆"
			rarity_label.modulate = Color.WHITE


func set_card_owner(new_owner: int) -> void:
	owner_id = new_owner
	update_owner_visual()


func update_owner_visual() -> void:
	if card_background == null:
		return
	if owner_id == 0:
		card_background.modulate = Color(0.75, 0.85, 1.0)
	else:
		card_background.modulate = Color(1.0, 0.75, 0.75)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_clicked.emit(self)


func set_card_hidden(hidden: bool) -> void:
	if card_back == null:
		return
	card_back.visible = hidden
	if artwork != null:
		artwork.visible = not hidden
	if rarity_label != null:
		rarity_label.visible = not hidden
	if up_value != null:
		up_value.visible = not hidden
	if right_value != null:
		right_value.visible = not hidden
	if down_value != null:
		down_value.visible = not hidden
	if left_value != null:
		left_value.visible = not hidden
	if name_label != null:
		name_label.visible = not hidden


func reveal_card() -> void:
	if card_back != null:
		card_back.visible = false
	if artwork != null:
		artwork.visible = true
	if rarity_label != null:
		rarity_label.visible = true
	if up_value != null:
		up_value.visible = true
	if right_value != null:
		right_value.visible = true
	if down_value != null:
		down_value.visible = true
	if left_value != null:
		left_value.visible = true
	if name_label != null:
		name_label.visible = true
	visible = true


func has_mythic_ability(ability_id: String) -> bool:
	if data == null:
		return false
	return data.rarity == CardData.Rarity.MYTHIC and data.mythic_ability == ability_id


func reset_combat_abilities() -> void:
	petrified = false
	petrify_used = false
	divine_shield_used = false
