extends Node

const COLLECTION_SAVE_PATH: String = "user://collection.cfg"
const BATTLE_HAND_SIZE: int = 5
const DECK_SIZE: int = 5

const BUFF_EXTRA_CARD_POWER: String = "extra_card_power"
const BUFF_WEAKENING_CURSE: String = "weakening_curse"

var run_active: bool = false

var run_encounter_count: int = 12
var run_boss_count: int = 2

var current_room_id: int = -1
var selected_room_id: int = -1
var map_data: Array[Dictionary] = []

var player_health: int = 5
var player_max_health: int = 5
var player_cards: Array[String] = []
var card_collection: Array[String] = []

var saved_deck: Array[String] = []
var battle_hand: Array[String] = []


var items: Array[String] = []
var relics: Array[String] = []

var active_combat_buffs: Array[String] = []
var game_difficulty: int = 1
var current_combat_type: String = ""
var offered_card_paths: Array[String] = []
var encounter_wins: int = 0
var encounter_wins_required: int = 1
var encounter_room_id: int = -1


func _ready() -> void:
	load_card_collection()


func start_new_run() -> void:
	clear_encounter_progress()
	run_active = true
	current_room_id = -1
	selected_room_id = -1
	map_data.clear()
	player_health = player_max_health
	player_cards.clear()
	items.clear()
	setup_starting_deck()
	battle_hand.clear()
	print("New run started.")


func setup_starting_deck() -> void:
	player_cards.clear()
	for card_path: String in saved_deck:
		player_cards.append(card_path)


func end_run() -> void:
	run_active = false
	current_room_id = -1
	selected_room_id = -1
	map_data.clear()
	player_cards.clear()
	items.clear()
	print("Run ended.")
	battle_hand.clear()
	clear_encounter_progress()


func complete_selected_room() -> void:
	if selected_room_id == -1:
		return
	var completed_room: Dictionary = {}
	for room in map_data:
		room["available"] = false
	for room in map_data:
		if room["id"] == selected_room_id:
			room["completed"] = true
			completed_room = room
			break
	if completed_room.is_empty():
		return
	for connection_id in completed_room["connections"]:
		for room in map_data:
			if room["id"] == connection_id:
				room["available"] = true
				break
	current_room_id = selected_room_id
	selected_room_id = -1


func player_defeated() -> void:
	run_active = false
	clear_battle_hand()
	clear_encounter_progress()
	print("Run failed.")


func is_player_dead() -> bool:
	return player_health <= 0


func lose_run() -> void:
	RunManager.player_defeated()
	get_tree().change_scene_to_file("res://menus/GameOver.tscn")


func set_combat_type(combat_type: String) -> void:
	current_combat_type = combat_type


func is_run_complete() -> bool:
	for room: Dictionary in map_data:
		var room_type: int = int(room["type"])
		var completed: bool = bool(room["completed"])
		if (room_type == RoomData.RoomType.BOSS and not completed):
			return false
	return true


func start_combat_encounter(room_id: int, combat_type: String) -> void:
	current_combat_type = combat_type
	if encounter_room_id != room_id:
		encounter_room_id = room_id
		encounter_wins = 0
	match combat_type:
		"elite":
			encounter_wins_required = 2
		"boss":
			encounter_wins_required = 3
		_:
			encounter_wins_required = 1


func add_encounter_win() -> bool:
	encounter_wins += 1
	return encounter_wins >= encounter_wins_required


func clear_encounter_progress() -> void:
	encounter_wins = 0
	encounter_wins_required = 1
	encounter_room_id = -1


func unlock_card(card_path: String) -> void:
	if card_path.is_empty():
		return
	if card_collection.has(card_path):
		return
	if not ResourceLoader.exists(card_path):
		push_warning("Cannot unlock missing card: " + card_path)
		return
	card_collection.append(card_path)
	save_card_collection()
	print("Unlocked card: ", card_path)


func is_card_unlocked(card_path: String) -> bool:
	return card_collection.has(card_path)


func setup_starting_collection() -> void:
	if not card_collection.is_empty():
		return
	unlock_card("res://GameManager/Card/Type/dragons/RedDragon.tres")
	unlock_card("res://GameManager/Card/Type/humanoid/Elf(high).tres")
	unlock_card("res://GameManager/Card/Type/monstrosity/Manticore.tres")
	unlock_card("res://GameManager/Card/Type/outsider/Angel.tres")
	unlock_card("res://GameManager/Card/Type/plants/Trap.tres")


func save_card_collection() -> void:
	var config := ConfigFile.new()
	config.set_value("collection", "unlocked_cards", card_collection)
	config.set_value("deck", "selected_cards", saved_deck)
	var error: Error = config.save(COLLECTION_SAVE_PATH)
	if error != OK:
		push_error("Failed to save card data. Error: " + str(error))
		return
	print("Card collection and deck saved.")


func load_card_collection() -> void:
	var config := ConfigFile.new()
	var error: Error = config.load(COLLECTION_SAVE_PATH)
	if error != OK:
		print("No collection save found. " + "Creating starting collection.")
		setup_starting_collection()
		save_card_collection()
		return
	var saved_cards: Variant = config.get_value("collection", "unlocked_cards", [])
	card_collection.clear()
	if saved_cards is Array:
		for card_path: Variant in saved_cards:
			if card_path is String:
				card_collection.append(String(card_path))
	print("Loaded ", card_collection.size(), " unlocked cards.")
	var saved_deck_data: Variant = config.get_value("deck", "selected_cards", [])
	saved_deck.clear()
	if saved_deck_data is Array:
		for card_path: Variant in saved_deck_data:
			if card_path is String:
				var path: String = String(card_path)
				if (card_collection.has(path) and ResourceLoader.exists(path)):
					saved_deck.append(path)
	if saved_deck.is_empty():
		setup_default_deck()
		save_card_collection()


func setup_default_deck() -> void:
	saved_deck.clear()
	for card_path: String in card_collection:
		if saved_deck.size() >= DECK_SIZE:
			break
		saved_deck.append(card_path)


func clear_battle_hand() -> void:
	battle_hand.clear()


func set_battle_hand(selected_cards: Array[String]) -> void:
	battle_hand.clear()
	for card_path: String in selected_cards:
		if battle_hand.size() >= BATTLE_HAND_SIZE:
			break
		if player_cards.has(card_path):
			battle_hand.append(card_path)


func battle_hand_is_ready() -> bool:
	return battle_hand.size() == BATTLE_HAND_SIZE


func add_combat_buff(buff_id: String) -> void:
	if buff_id.is_empty():
		return
	active_combat_buffs.append(buff_id)
	print("Added combat buff: ", buff_id)


func has_combat_buff(buff_id: String) -> bool:
	return active_combat_buffs.has(buff_id)


func consume_combat_buffs() -> void:
	active_combat_buffs.clear()
	print("Combat buffs cleared.")

































#
