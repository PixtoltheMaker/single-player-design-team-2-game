extends Control

const BATTLE_HAND_SIZE: int = 5

const DECK_CARD_SCENE: PackedScene = preload("res://menus/deck_card_button.tscn")

@onready var available_grid: GridContainer = $MarginContainer/VBoxContainer/Content/AvailablePanel/AvailableVBox/AvailableScroll/AvailableGrid
@onready var hand_list: VBoxContainer = $MarginContainer/VBoxContainer/Content/HandPanel/HandVBox/HandList
@onready var combat_type_label: Label = $MarginContainer/VBoxContainer/Header/CombatTypeLabel
@onready var hand_count_label: Label = $MarginContainer/VBoxContainer/Header/HandCountLabel
@onready var start_battle_button: Button = $MarginContainer/VBoxContainer/ButtonBar/StartBattleButton

var selected_hand: Array[String] = []


func _ready() -> void:
	print("========== BATTLE HAND ==========")
	print("Player cards: ", RunManager.player_cards)
	print("Player card count: ", RunManager.player_cards.size())
	print("Saved deck: ", RunManager.saved_deck)
	print("Saved deck count: ", RunManager.saved_deck.size())
	print("=================================")

	setup_combat_label()
	create_available_cards()
	update_hand_display()


func setup_combat_label() -> void:
	match RunManager.current_combat_type:
		"normal":
			combat_type_label.text = "NORMAL COMBAT"
		"elite":
			combat_type_label.text = "ELITE COMBAT"
		"boss":
			combat_type_label.text = "BOSS BATTLE"
		_:
			combat_type_label.text = "COMBAT"


func create_available_cards() -> void:
	for child: Node in available_grid.get_children():
		child.queue_free()
	print("Creating battle cards: ", RunManager.player_cards.size())
	for card_path: String in RunManager.player_cards:
		print("Loading battle card: ", card_path)
		if not ResourceLoader.exists(card_path):
			push_error("Battle card does not exist: " + card_path)
			continue
		var resource: Resource = load(card_path)
		if resource == null:
			push_error("Could not load: " + card_path)
			continue
		if not resource is CardData:
			push_error("Not CardData: " + card_path)
			continue
		var card_data: CardData = resource as CardData
		var button: DeckCardButton = DECK_CARD_SCENE.instantiate() as DeckCardButton
		if button == null:
			push_error("Could not create DeckCardButton.")
			continue
		available_grid.add_child(button)
		button.setup(card_path, card_data)
		button.card_pressed.connect(_on_available_card_pressed)
		print("Displayed battle card: ", card_data.card_name)


func _on_available_card_pressed(card_path: String) -> void:
	if selected_hand.size() >= BATTLE_HAND_SIZE:
		return
	if selected_hand.has(card_path):
		return
	selected_hand.append(card_path)
	update_hand_display()


func update_hand_display() -> void:
	for child: Node in hand_list.get_children():
		child.queue_free()
	for card_path: String in selected_hand:
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
		hand_list.add_child(button)
	hand_count_label.text = ("Hand: " + str(selected_hand.size()) + " / " + str(BATTLE_HAND_SIZE))
	start_battle_button.disabled = (selected_hand.size() != BATTLE_HAND_SIZE)


func _remove_card(card_path: String) -> void:
	var index: int = selected_hand.find(card_path)
	if index == -1:
		return
	selected_hand.remove_at(index)
	update_hand_display()


func _on_auto_select_button_pressed() -> void:
	selected_hand.clear()
	var amount: int = mini(BATTLE_HAND_SIZE, RunManager.player_cards.size())
	for i: int in range(amount):
		selected_hand.append(RunManager.player_cards[i])
	update_hand_display()


func _on_start_battle_button_pressed() -> void:
	if selected_hand.size() != BATTLE_HAND_SIZE:
		return
	RunManager.set_battle_hand(selected_hand)
	if not RunManager.battle_hand_is_ready():
		return
	get_tree().change_scene_to_file("res://GameManager/Board/game.tscn")


func _on_back_button_pressed() -> void:
	RunManager.clear_battle_hand()
	get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")
















#
