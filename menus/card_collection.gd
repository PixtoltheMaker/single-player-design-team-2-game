extends Control

const LOCKED_CARD_SCENE = preload("res://GameManager/Card/LockedCard.tscn")
const CARD_SCENE = preload("res://GameManager/Card/card.tscn")

const PLAYER: int = 0

@onready var card_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardGrid
@onready var details_panel: Panel = $CardDetailsPanel
@onready var selected_name_label: Label = $CardDetailsPanel/VBoxContainer/SelectedNameLabel
@onready var selected_artwork: TextureRect = $CardDetailsPanel/VBoxContainer/SelectedArtwork
@onready var values_label: Label = $CardDetailsPanel/VBoxContainer/ValuesLabel
@onready var description_label: Label = $CardDetailsPanel/VBoxContainer/DescriptionLabel

var all_card_paths: Array[String] = []


func _ready() -> void:
	load_all_cards()
	build_collection()
	details_panel.visible = false


func load_all_cards() -> void:
	all_card_paths.clear()
	scan_card_folder("res://GameManager/Card/Type")
	print("Collection found ", all_card_paths.size(), " cards.")
	print("Collection found ", all_card_paths.size(), " cards.")


func scan_card_folder(folder_path: String) -> void:
	var directory: DirAccess = DirAccess.open(folder_path)
	if directory == null:
		push_error("Could not open card folder: " + folder_path)
		return
	directory.list_dir_begin()
	while true:
		var file_name: String = directory.get_next()
		if file_name.is_empty():
			break
		if file_name == "." or file_name == "..":
			continue
		var full_path: String = folder_path + "/" + file_name
		if directory.current_is_dir():
			scan_card_folder(full_path)
			continue
		if file_name.ends_with(".tres"):
			var card_data: CardData = load(full_path) as CardData
			if card_data != null:
				all_card_paths.append(full_path)
	directory.list_dir_end()


func build_collection() -> void:
	for child: Node in card_container.get_children():
		child.queue_free()
	for card_path: String in all_card_paths:
		create_card_variants(card_path)


func create_card_variants(card_path: String) -> void:
	var base_card: CardData = load(card_path) as CardData
	if base_card == null:
		return
	var normal_card: CardData = base_card.duplicate() as CardData
	normal_card.rarity = CardData.Rarity.NORMAL
	create_collection_entry(
		card_path,
		CardData.Rarity.NORMAL,
		normal_card
	)
	var rare_card: CardData = CardVariantGenerator.create_variant(
		card_path,
		CardData.Rarity.RARE
	)
	if rare_card != null:
		create_collection_entry(
			card_path,
			CardData.Rarity.RARE,
			rare_card
		)
	var mythic_card: CardData = CardVariantGenerator.create_variant(
		card_path,
		CardData.Rarity.MYTHIC
	)
	if mythic_card != null:
		create_collection_entry(
			card_path,
			CardData.Rarity.MYTHIC,
			mythic_card
		)


func create_collection_entry(card_path: String, rarity: CardData.Rarity, generated_card: CardData) -> void:
	var saved_variant: Dictionary = get_saved_variant(card_path, rarity)
	if not saved_variant.is_empty():
		var saved_card: CardData = RunManager.create_saved_card_variant(saved_variant)
		if saved_card != null:
			create_unlocked_card(saved_card)
		return
	create_locked_card(generated_card)


func get_saved_variant(card_path: String, rarity: CardData.Rarity) -> Dictionary:
	for variant: Dictionary in RunManager.card_collection_variants:
		var saved_path: String = str(variant.get("path", ""))
		var saved_rarity: int = int(variant.get("rarity", CardData.Rarity.NORMAL))
		if saved_path == card_path:
			if saved_rarity == int(rarity):
				return variant
	return {}


func create_unlocked_card(card_data: CardData) -> void:
	var card_instance: GameCard = CARD_SCENE.instantiate() as GameCard
	if card_instance == null:
		return
	card_instance.data = card_data
	card_instance.set_card_owner(PLAYER)
	card_instance.custom_minimum_size = Vector2(180, 250)
	card_container.add_child(card_instance)
	card_instance.card_clicked.connect(_on_card_clicked)


func create_locked_card(card_data: CardData) -> void:
	var locked_card: Control = LOCKED_CARD_SCENE.instantiate() as Control
	if locked_card == null:
		return
	locked_card.custom_minimum_size = Vector2(180, 250)
	var question_mark: Label = locked_card.get_node_or_null("QuestionMark") as Label
	if question_mark != null:
		question_mark.text = "?"
	var rarity_label: Label = locked_card.get_node_or_null("RarityLabel") as Label
	if rarity_label != null:
		match card_data.rarity:
			CardData.Rarity.NORMAL:
				rarity_label.text = "◆"
			CardData.Rarity.RARE:
				rarity_label.text = "◆◆"
			CardData.Rarity.MYTHIC:
				rarity_label.text = "◆◆◆"
	card_container.add_child(locked_card)


func _on_deck_builder_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/DeckBuilder.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")


func _on_card_clicked(card: GameCard) -> void:
	if card == null:
		return
	if card.data == null:
		return
	var card_data: CardData = card.data
	details_panel.visible = true
	selected_name_label.text = card_data.card_name
	selected_artwork.texture = card_data.artwork
	values_label.text = (
		"UP: " + str(card_data.up) +
		"\nRIGHT: " + str(card_data.right) +
		"\nDOWN: " + str(card_data.down) +
		"\nLEFT: " + str(card_data.left)
	)
	description_label.text = get_card_description(card_data)


func get_card_description(card_data: CardData) -> String:
	var text: String = ""
	match card_data.rarity:
		CardData.Rarity.NORMAL:
			text += "◆ Normal"
		CardData.Rarity.RARE:
			text += "◆◆ Rare"
		CardData.Rarity.MYTHIC:
			text += "◆◆◆ Mythic"
			if not card_data.mythic_ability.is_empty():
				text += "\n\nMythic Ability: "
				text += card_data.mythic_ability
			if not card_data.mythic_description.is_empty():
				text += "\n"
				text += card_data.mythic_description
	return text























#
