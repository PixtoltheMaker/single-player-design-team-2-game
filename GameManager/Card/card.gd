class_name GameCard
extends Control

signal card_clicked(card: GameCard)

@export var data: CardData

var owner_id: int = 0
var board_position: Vector2i = Vector2i(-1, -1)
var starting_position: Vector2
var is_selected: bool = false

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
@onready var bonus_container: VBoxContainer = $BonusContainer
@onready var bonus_label: Label = $BonusContainer/BonusLabel

var petrified: bool = false
var petrify_used: bool = false
var divine_shield_used: bool = false

var displayed_bonus: int = 0
var bonus_sources: Array[Dictionary] = []
var bonus_tooltip: String = ""


func _ready() -> void:
	update_card()
	update_owner_visual()
	clear_bonus_display()


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


func set_card_hidden(is_hidden: bool) -> void:
	if card_back == null:
		return
	card_back.visible = is_hidden
	if artwork != null:
		artwork.visible = not is_hidden
	if rarity_label != null:
		rarity_label.visible = not is_hidden
	if up_value != null:
		up_value.visible = not is_hidden
	if right_value != null:
		right_value.visible = not is_hidden
	if down_value != null:
		down_value.visible = not is_hidden
	if left_value != null:
		left_value.visible = not is_hidden
	if name_label != null:
		name_label.visible = not is_hidden


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


func clear_bonus_display() -> void:
	displayed_bonus = 0
	bonus_sources.clear()
	bonus_tooltip = ""
	if bonus_container != null:
		bonus_container.hide()
	tooltip_text = ""


func set_bonus_sources(sources: Array[Dictionary]) -> void:
	bonus_sources = sources.duplicate(true)
	displayed_bonus = 0
	var has_item: bool = false
	var has_buff: bool = false
	var has_mythic: bool = false
	var has_enemy: bool = false
	for source: Dictionary in bonus_sources:
		var amount: int = int(source.get("amount", 0))
		var bonus_type: String = str(source.get("type", ""))
		displayed_bonus += amount
		match bonus_type:
			"item", "relic":
				has_item = true
			"buff":
				has_buff = true
			"mythic":
				has_mythic = true
			"enemy":
				has_enemy = true
	if bonus_sources.is_empty():
		clear_bonus_display()
		return
	var display_text: String = ""
	if has_item:
		display_text += "⚔ "
	if has_buff:
		display_text += "⚡ "
	if has_mythic:
		display_text += "✦ "
	if has_enemy:
		display_text += "♛ "
	if displayed_bonus >= 0:
		display_text += "+" + str(displayed_bonus)
	else:
		display_text += str(displayed_bonus)
	bonus_label.text = display_text
	update_bonus_color()
	update_bonus_tooltip()
	bonus_container.show()


func update_bonus_color() -> void:
	var has_mythic: bool = false
	var has_buff: bool = false
	var has_enemy: bool = false
	for source: Dictionary in bonus_sources:
		var bonus_type: String = str(source.get("type", ""))
		match bonus_type:
			"mythic":
				has_mythic = true
			"buff":
				has_buff = true
			"enemy":
				has_enemy = true
	if has_mythic:
		bonus_label.add_theme_color_override(
			"font_color",
			Color(0.75, 0.45, 1.0)
		)
	elif has_buff:
		bonus_label.add_theme_color_override(
			"font_color",
			Color(0.4, 0.75, 1.0)
		)
	elif has_enemy:
		bonus_label.add_theme_color_override(
			"font_color",
			Color(1.0, 0.4, 0.4)
		)
	else:
		bonus_label.add_theme_color_override(
			"font_color",
			Color(0.4, 1.0, 0.5)
		)


func update_bonus_tooltip() -> void:
	if data == null:
		return
	var tooltip: String = data.card_name + "\n"
	tooltip += "--------------------\n"
	tooltip += "Base Values:\n"
	tooltip += "UP: " + str(data.up) + "\n"
	tooltip += "RIGHT: " + str(data.right) + "\n"
	tooltip += "DOWN: " + str(data.down) + "\n"
	tooltip += "LEFT: " + str(data.left) + "\n"
	tooltip += "\nActive Bonuses:\n"
	for source: Dictionary in bonus_sources:
		var source_name: String = str(source.get("name", "Bonus"))
		var amount: int = int(source.get("amount", 0))
		var amount_text: String = str(amount)
		if amount >= 0:
			amount_text = "+" + str(amount)
		tooltip += source_name + ": " + amount_text + "\n"
	tooltip += "--------------------\n"
	tooltip += "Displayed Bonus: "
	if displayed_bonus >= 0:
		tooltip += "+" + str(displayed_bonus)
	else:
		tooltip += str(displayed_bonus)
	bonus_tooltip = tooltip
	tooltip_text = bonus_tooltip


func save_starting_position() -> void:
	starting_position = position


func return_to_starting_position() -> void:
	position = starting_position
	is_selected = false
