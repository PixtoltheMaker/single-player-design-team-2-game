extends Control

const COLLECTION_CARD_SCENE: PackedScene = preload("res://menus/CollectionCardButton.tscn")

@onready var card_grid: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/CardGrid
@onready var card_count_label: Label = $MarginContainer/VBoxContainer/Header/CardCountLabel
@onready var selected_name_label: Label = $CardDetailsPanel/VBoxContainer/SelectedNameLabel
@onready var selected_artwork: TextureRect = $CardDetailsPanel/VBoxContainer/SelectedArtwork
@onready var values_label: Label = $CardDetailsPanel/VBoxContainer/ValuesLabel



func _ready() -> void:
	create_collection()
	clear_details()


func create_collection() -> void:
	for child: Node in card_grid.get_children():
		child.queue_free()
	var unlocked_count: int = 0
	var total_count: int = 0
	for card_path: String in CardDatabase.ALL_CARDS:
		var resource: Resource = load(card_path)
		if not resource is CardData:
			push_warning("Invalid card resource: " + card_path)
			continue
		var card_data: CardData = resource as CardData
		var unlocked: bool = RunManager.is_card_unlocked(card_path)
		if unlocked:
			unlocked_count += 1
		total_count += 1
		var card_button: CollectionCardButton = COLLECTION_CARD_SCENE.instantiate() as CollectionCardButton
		card_grid.add_child(card_button)
		card_button.setup(card_data, unlocked)
		card_button.card_selected.connect(_on_card_selected)
	card_count_label.text = (str(unlocked_count) + " / " + str(total_count) + " Cards")


func _on_card_selected(card_data: CardData, unlocked: bool) -> void:
	if not unlocked:
		show_locked_details()
		return
	selected_name_label.text = card_data.card_name
	selected_artwork.texture = card_data.artwork
	selected_artwork.modulate = Color.WHITE
	values_label.text = ("UP: " + str(card_data.up) + "\nRIGHT: " + str(card_data.right) + "\nDOWN: " + str(card_data.down) + "\nLEFT: " + str(card_data.left))


func clear_details() -> void:
	selected_name_label.text = "Select a Card"
	selected_artwork.texture = null
	selected_artwork.modulate = Color.WHITE
	values_label.text = ("UP: -" + "\nRIGHT: -" + "\nDOWN: -" + "\nLEFT: -")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")


func _on_deck_builder_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/DeckBuilder.tscn")


func show_locked_details() -> void:
	selected_name_label.text = "???"
	selected_artwork.texture = null
	values_label.text = ("UP: ?" + "\nRIGHT: ?" + "\nDOWN: ?" + "\nLEFT: ?")
















#
