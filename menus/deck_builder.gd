extends Control


const DECK_CARD_SCENE: PackedScene = preload("res://menus/Deck_Card_Button.tscn")
const DECK_SIZE: int = 5

@onready var collection_grid: GridContainer = $MarginContainer/VBoxContainer/Content/CollectionPanel/VBoxContainer/ScrollContainer/CollectionGrid
@onready var deck_list: VBoxContainer = $MarginContainer/VBoxContainer/Content/DeckPanel/VBoxContainer/DeckList
@onready var deck_count_label: Label = $MarginContainer/VBoxContainer/Header/DeckCountLabel
@onready var save_deck_button: Button = $MarginContainer/VBoxContainer/SaveDeckButton

var working_deck: Array[String] = []


func _ready() -> void:
	print("========== DECK BUILDER ==========")
	print("Collection size: ", RunManager.card_collection.size())
	for card_path: String in RunManager.card_collection:
		print("Unlocked card: ", card_path)
	working_deck = RunManager.saved_deck.duplicate()
	create_collection()
	update_deck_display()
	print("==================================")


func create_collection() -> void:
	for child: Node in collection_grid.get_children():
		child.queue_free()
	print("========== DECK BUILDER ==========")
	print("Collection size: ", RunManager.card_collection.size())
	for card_path: String in RunManager.card_collection:
		print("Trying collection card: ", card_path)
		if not ResourceLoader.exists(card_path):
			push_error("Card file does not exist: " + card_path)
			continue
		var resource: Resource = load(card_path)
		if resource == null:
			push_error("Could not load card: " + card_path)
			continue
		if not resource is CardData:
			push_error("Not CardData: " + card_path)
			continue
		var card_data: CardData = resource as CardData
		print("Creating button for: ", card_data.card_name)
		var button: DeckCardButton = DECK_CARD_SCENE.instantiate() as DeckCardButton
		if button == null:
			push_error("Could not instantiate DeckCardButton.")
			continue
		collection_grid.add_child(button)
		button.setup(card_path, card_data)
		button.card_pressed.connect(_on_collection_card_pressed)
	print("Buttons created: ", collection_grid.get_child_count())
	print("===================================")


func _on_collection_card_pressed(card_path: String) -> void:
	if working_deck.size() >= DECK_SIZE:
		print("Deck is full.")
		return
	if working_deck.has(card_path):
		print("Card already in deck.")
		return
	working_deck.append(card_path)
	update_deck_display()


func update_deck_display() -> void:
	for child: Node in deck_list.get_children():
		child.queue_free()
	for card_path: String in working_deck:
		if not ResourceLoader.exists(card_path):
			continue
		var resource: Resource = load(card_path)
		if not resource is CardData:
			continue
		var card_data: CardData = resource as CardData
		var button := Button.new()
		button.text = (card_data.card_name + "   [REMOVE]")
		button.custom_minimum_size = Vector2(250.0, 50.0)
		button.pressed.connect(_remove_card.bind(card_path))
		deck_list.add_child(button)
	deck_count_label.text = ("Deck: " + str(working_deck.size()) + " / " + str(DECK_SIZE))
	save_deck_button.disabled = (working_deck.size() != DECK_SIZE)


func _remove_card(card_path: String) -> void:
	var index: int = working_deck.find(card_path)
	if index == -1:
		return
	working_deck.remove_at(index)
	update_deck_display()


func _on_save_deck_button_pressed() -> void:
	if working_deck.size() != DECK_SIZE:
		print("Deck must contain exactly ", DECK_SIZE, " cards.")
		return
	RunManager.saved_deck.clear()
	for card_path: String in working_deck:
		RunManager.saved_deck.append(card_path)
	RunManager.save_card_collection()
	print("Deck saved.")
	get_tree().change_scene_to_file("res://menus/Card_Collection.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/card_collection.tscn")


func _on_deck_builder_button_pressed() -> void:
		get_tree().change_scene_to_file("res://menus/DeckBuilder.tscn")





































#
