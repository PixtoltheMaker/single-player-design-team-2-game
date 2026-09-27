extends Control

const PLAYER := 0
const COMPUTER := 1
const CARD_SCENE: PackedScene = preload("res://GameManager/Card/card.tscn")

enum AIDifficulty {
	NORMAL,
	MEDIUM,
	HARD
}

var normal_enemy_pool: Array[String] = [
	"res://GameManager/Card/Type/humanoid/Dwarf.tres",
	"res://GameManager/Card/Type/humanoid/Elf(high).tres",
	"res://GameManager/Card/Type/humanoid/Elf(wild).tres",
	"res://GameManager/Card/Type/humanoid/Human.tres",
	"res://GameManager/Card/Type/outsider/Angel.tres"
]


var elite_enemy_pool: Array[String] = [
	"res://GameManager/Card/Type/dragons/RedDragon.tres",
	"res://GameManager/Card/Type/humanoid/Dwarf.tres",
	"res://GameManager/Card/Type/monstrosity/Hydra.tres",
	"res://GameManager/Card/Type/outsider/Angel.tres",
	"res://GameManager/Card/Type/plants/Mandrake.tres"
]


var boss_enemy_pool: Array[String] = [
	"res://GameManager/Card/Type/dragons/RedDragon.tres",
	"res://GameManager/Card/Type/dragons/GreenDragon.tres",
	"res://GameManager/Card/Type/dragons/BlackDragon.tres",
	"res://GameManager/Card/Type/dragons/BlueDragon.tres",
	"res://GameManager/Card/Type/monstrosity/Hydra.tres"
	]

var ai_difficulty: AIDifficulty = AIDifficulty.NORMAL
var difficulty_selected: bool = false
var board: Array = [
	null, null, null,
	null, null, null,
	null, null, null
]

@onready var board_container: GridContainer = $CenterContainer/Board
@onready var player_hand: VBoxContainer = $PlayerHand
@onready var opponent_hand: VBoxContainer = $OpponentHand
@onready var turn_label: Label = $UI/VBoxContainer/TurnLabel
@onready var player_score_label: Label = $UI/VBoxContainer/PlayerScore
@onready var enemy_score_label: Label = $UI/VBoxContainer/EnemyScore
@onready var result_label: Label = $UI/VBoxContainer/ResultLabel
@onready var combat_type_label: Label = $UI/CombatTypeLabel
@onready var health_label: Label = $UI/HealthLabel
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var continue_button: Button = $UI/ContinueButton
@onready var encounter_progress_label: Label = $UI/VBoxContainer/EncounterProgressLabel

var current_player: int = PLAYER
var selected_card: GameCard = null
var game_over: bool = false
var run_defeated: bool = false

var combat_buff_value_bonus: int = 0
var enemy_combat_value_bonus: int = 0


func _ready() -> void:
	for slot in board_container.get_children():
		if slot is BoardSlot:
			slot.slot_clicked.connect(_on_slot_clicked)
	for card in player_hand.get_children():
		if card is GameCard:
			card.set_card_owner(PLAYER)
			card.card_clicked.connect(_on_card_clicked)
	for card in opponent_hand.get_children():
		if card is GameCard:
			card.set_card_owner(COMPUTER)
	setup_combat_buffs()
	update_turn_label()
	update_score()
	setup_roguelite_combat()


func _on_slot_clicked(slot: BoardSlot) -> void:
	if game_over:
		return
	if current_player != PLAYER:
		return
	if selected_card == null:
		print("Select a card first.")
		return
	if slot.card != null:
		print("That space is occupied.")
		return
	var card := selected_card
	selected_card = null
	place_card(card, slot)
	finish_turn()


func _on_card_clicked(card: GameCard) -> void:
	if game_over:
		return
	if current_player != PLAYER:
		return
	if card.owner_id != PLAYER:
		return
	if selected_card != null:
		selected_card.position.y = 0
	selected_card = card
	selected_card.position.y = -20
	print("Selected: ", card.data.card_name)


func place_card(card: GameCard, slot: BoardSlot) -> void:
	var index := slot.slot_index
	board[index] = card
	slot.card = card
	card.board_position = Vector2i(index % 3, int(float(index) / 3.0))
	card.reparent(slot)
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.position = Vector2.ZERO
	check_captures(card)
	update_score()
	print(card.data.card_name, " placed in slot ", index)
	update_scores()


func get_card_at(board_position: Vector2i) -> GameCard:
	if board_position.x < 0 or board_position.x >= 3:
		return null
	if board_position.y < 0 or board_position.y >= 3:
		return null
	var index := board_position.y * 3 + board_position.x
	return board[index]


func check_captures(card: GameCard) -> void:
	var pos := card.board_position
	check_direction(card, pos + Vector2i.UP, "up")
	check_direction(card, pos + Vector2i.RIGHT, "right")
	check_direction(card, pos + Vector2i.DOWN, "down")
	check_direction(card, pos + Vector2i.LEFT, "left")


func check_direction(card: GameCard, target_position: Vector2i, direction: String) -> void:
	var enemy := get_card_at(target_position)
	if enemy == null:
		return
	if enemy.owner_id == card.owner_id:
		return
	var attack_value: int = 0
	var defense_value: int = 0
	match direction:
		"up":
			attack_value = card.data.up
			defense_value = enemy.data.down
		"right":
			attack_value = card.data.right
			defense_value = enemy.data.left
		"down":
			attack_value = card.data.down
			defense_value = enemy.data.up
		"left":
			attack_value = card.data.left
			defense_value = enemy.data.right
	if card.owner_id == PLAYER:
		attack_value += combat_buff_value_bonus
	if enemy.owner_id == COMPUTER:
		defense_value += enemy_combat_value_bonus
	print("Capture check: ", attack_value, " vs ", defense_value)
	if attack_value > defense_value:
		capture_card(enemy, card.owner_id)


func capture_card(card: GameCard, new_owner: int) -> void:
	card.set_card_owner(new_owner)
	print(card.data.card_name, " was captured!")
	update_scores()


func finish_turn() -> void:
	if board_full():
		end_game()
		return
	if current_player == PLAYER:
		current_player = COMPUTER
		update_turn_label()
		computer_turn()
	else:
		current_player = PLAYER
		update_turn_label()


func computer_turn() -> void:
	if game_over:
		return
	await get_tree().create_timer(0.75).timeout
	if game_over:
		return
	var available_cards: Array[GameCard] = []
	for child in opponent_hand.get_children():
		if child is GameCard:
			available_cards.append(child)
	var empty_slots: Array[BoardSlot] = get_empty_slots()
	if available_cards.is_empty() or empty_slots.is_empty():
		end_game()
		return
	match ai_difficulty:
		AIDifficulty.NORMAL:
			normal_ai_move(available_cards, empty_slots)
		AIDifficulty.MEDIUM:
			medium_ai_move(available_cards, empty_slots)
		AIDifficulty.HARD:
			hard_ai_move(available_cards, empty_slots)

func get_empty_slots() -> Array[BoardSlot]:
	var empty_slots: Array[BoardSlot] = []
	for child in board_container.get_children():
		if child is BoardSlot:
			if child.card == null:
				empty_slots.append(child)
	return empty_slots


func computer_place_card(card: GameCard) -> void:
	var empty_slots := get_empty_slots()
	if empty_slots.is_empty():
		end_game()
		return
	var chosen_slot: BoardSlot = empty_slots.pick_random()
	place_card(card, chosen_slot)
	finish_turn()


func board_full() -> bool:
	for space in board:
		if space == null:
			return false
	return true


func get_scores() -> Array[int]:
	var player_score := 0
	var computer_score := 0
	for card in board:
		if card == null:
			continue
		if card.owner_id == PLAYER:
			player_score += 1
		elif card.owner_id == COMPUTER:
			computer_score += 1
	for child in player_hand.get_children():
		if child is GameCard:
			player_score += 1
	for child in opponent_hand.get_children():
		if child is GameCard:
			computer_score += 1
	return [player_score, computer_score]


func update_score() -> void:
	var scores := get_scores()
	player_score_label.text = "Player: " + str(scores[0])
	enemy_score_label.text = "Computer: " + str(scores[1])


func update_turn_label() -> void:
	if current_player == PLAYER:
		turn_label.text = "Your Turn"
	else:
		turn_label.text = "Computer's Turn"


func end_game() -> void:
	if game_over:
		return
	game_over = true
	var scores: Array[int] = get_scores()
	var player_score: int = scores[0]
	var computer_score: int = scores[1]
	update_scores()
	resolve_combat(player_score, computer_score)


func _on_continue_button_pressed() -> void:
	if run_defeated:
		get_tree().change_scene_to_file("res://menus/GameOver.tscn")
		return
	var encounter_complete: bool = (RunManager.encounter_room_id == -1)
	if encounter_complete:
		get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")
		return
	get_tree().reload_current_scene()


func evaluate_move(card: GameCard, slot: BoardSlot) -> int:
	var score: int = 0
	var index := slot.slot_index
	@warning_ignore("shadowed_variable_base_class")
	var position := Vector2i(index % 3, int(float(index) / 3.0))
	score += evaluate_capture(card.data.up, position + Vector2i.UP, "down")
	score += evaluate_capture(card.data.right, position + Vector2i.RIGHT,"left")
	score += evaluate_capture(card.data.down, position + Vector2i.DOWN, "up")
	score += evaluate_capture(card.data.left, position + Vector2i.LEFT, "right")
	if position.y == 0:
		score += 10 - card.data.up
	if position.y == 2:
		score += 10 - card.data.down
	if position.x == 0:
		score += 10 - card.data.left
	if position.x == 2:
		score += 10 - card.data.right
	if is_corner(position):
		score += 5
	score -= evaluate_danger(card, position)
	return score


func evaluate_capture(attack_value: int, target_position: Vector2i, enemy_side: String) -> int:
	var target := get_card_at(target_position)
	if target == null:
		return 0
	if target.owner_id == COMPUTER:
		return 0
	var defense_value: int = 0
	match enemy_side:
		"up":
			defense_value = target.data.up
		"right":
			defense_value = target.data.right
		"down":
			defense_value = target.data.down
		"left":
			defense_value = target.data.left
	if attack_value > defense_value:
		return 100

	return 0


func is_corner(board_position: Vector2i) -> bool:
	return (
		board_position == Vector2i(0, 0)
		or board_position == Vector2i(2, 0)
		or board_position == Vector2i(0, 2)
		or board_position == Vector2i(2, 2)
	)


func evaluate_danger(card: GameCard, board_position: Vector2i) -> int:
	var danger: int = 0
	if position.y > 0:
		if get_card_at(board_position + Vector2i.UP) == null:
			danger += get_side_threat(card.data.up, "down")
	if position.x < 2:
		if get_card_at(board_position + Vector2i.RIGHT) == null:
			danger += get_side_threat(card.data.right, "left")
	if position.y < 2:
		if get_card_at(board_position + Vector2i.DOWN) == null:
			danger += get_side_threat(card.data.down, "up")
	if position.x > 0:
		if get_card_at(board_position + Vector2i.LEFT) == null:
			danger += get_side_threat(card.data.left, "right")
	return danger


func side_danger(side_value: int) -> int:
	var danger: int = 0
	for child in player_hand.get_children():
		if child is not GameCard:
			continue
		var player_card: GameCard = child
		if player_card.data.up > side_value:
			danger += 2
		if player_card.data.right > side_value:
			danger += 2
		if player_card.data.down > side_value:
			danger += 2
		if player_card.data.left > side_value:
			danger += 2
	return danger


func get_side_threat(defense_value: int, attacking_side: String) -> int:
	var threat: int = 0
	for child in player_hand.get_children():
		if child is not GameCard:
			continue
		var player_card: GameCard = child
		var attack_value: int = 0
		match attacking_side:
			"up":
				attack_value = player_card.data.up
			"right":
				attack_value = player_card.data.right
			"down":
				attack_value = player_card.data.down
			"left":
				attack_value = player_card.data.left
		if attack_value > defense_value:
			threat += 5
	return threat


func setup_ai_difficulty() -> void:
	match RunManager.current_combat_type:
		"normal":
			ai_difficulty = AIDifficulty.NORMAL
		"elite":
			ai_difficulty = AIDifficulty.HARD
		"boss":
			ai_difficulty = AIDifficulty.HARD
		_:
			ai_difficulty = AIDifficulty.NORMAL


func normal_ai_move(available_cards: Array[GameCard], empty_slots: Array[BoardSlot]) -> void:
	if randf() < 0.25:
		medium_ai_move(available_cards, empty_slots)
		return
	var chosen_card: GameCard = available_cards.pick_random()
	var chosen_slot: BoardSlot = empty_slots.pick_random()
	place_card(chosen_card, chosen_slot)
	finish_turn()


func medium_ai_move(available_cards: Array[GameCard], empty_slots: Array[BoardSlot])  -> void:
	if randf() < 0.20:
		var random_card: GameCard = available_cards.pick_random()
		var random_slot: BoardSlot = empty_slots.pick_random()
		place_card(random_card, random_slot)
		finish_turn()
		return
	var best_card: GameCard = null
	var best_slot: BoardSlot = null
	var best_score: int = -999999
	for card in available_cards:
		for slot in empty_slots:
			var score := evaluate_move(card, slot)
			score += randi_range(0, 2)
			if score > best_score:
				best_score = score
				best_card = card
				best_slot = slot
	if best_card != null and best_slot != null:
		place_card(best_card, best_slot)

	finish_turn()


func hard_ai_move(available_cards: Array[GameCard], empty_slots: Array[BoardSlot]) -> void:
	var best_card: GameCard = null
	var best_slot: BoardSlot = null
	var best_score: int = -999999
	for card in available_cards:
		for slot in empty_slots:
			var score := evaluate_move(card, slot)
			score += evaluate_future_danger(card, slot)
			if score > best_score:
				best_score = score
				best_card = card
				best_slot = slot
	if best_card != null and best_slot != null:
		print("Hard AI chooses ", best_card.data.card_name, " -> Slot ", best_slot.slot_index, " Score: ", best_score)
		place_card(best_card, best_slot)
	finish_turn()


func evaluate_future_danger(card: GameCard, slot: BoardSlot) -> int:
	var score: int = 0
	var board_position := Vector2i(slot.slot_index % 3, int(float(slot.slot_index) / 3.0))
	if board_position.y > 0:
		if get_card_at(board_position + Vector2i.UP) == null:
			score -= get_side_threat(card.data.up, "down")
	if board_position.x < 2:
		if get_card_at(board_position + Vector2i.RIGHT) == null:
			score -= get_side_threat(card.data.right, "left")
	if board_position.y < 2:
		if get_card_at(board_position + Vector2i.DOWN) == null:
			score -= get_side_threat(card.data.down, "up")
	if board_position.x > 0:
		if get_card_at(board_position + Vector2i.LEFT) == null:
			score -= get_side_threat(card.data.left, "right")
	return score


func setup_enemy() -> void:
	match RunManager.current_combat_type:
		"normal":
			ai_difficulty = AIDifficulty.NORMAL
		"elite":
			ai_difficulty = AIDifficulty.MEDIUM
		"boss":
			ai_difficulty = AIDifficulty.HARD


func setup_roguelite_combat() -> void:
	continue_button.hide()
	setup_combat_type()
	update_health_display()
	create_player_hand_from_run()
	create_enemy_hand()
	update_encounter_progress()
	current_player = PLAYER
	game_over = false
	update_turn_label()
	update_scores()

func update_health_display() -> void:
	health_label.text = ("HP: " + str(RunManager.player_health) + " / " + str(RunManager.player_max_health))
	health_bar.max_value = RunManager.player_max_health
	health_bar.value = RunManager.player_health


func setup_combat_type() -> void:
	match RunManager.current_combat_type:
		"normal":
			combat_type_label.text = "NORMAL COMBAT"
		"elite":
			combat_type_label.text = "ELITE COMBAT"
		"boss":
			combat_type_label.text = "BOSS BATTLE"
		_:
			combat_type_label.text = "COMBAT"
	setup_ai_difficulty()


func create_player_hand_from_run() -> void:
	for child: Node in player_hand.get_children():
		child.queue_free()
	for card_path: String in RunManager.battle_hand:
		if not ResourceLoader.exists(card_path):
			continue
		var resource: Resource = load(card_path)
		if not resource is CardData:
			continue
		var card_data: CardData = resource as CardData
		var card: GameCard = CARD_SCENE.instantiate() as GameCard
		if card == null:
			continue
		card.data = card_data
		card.set_card_owner(PLAYER)
		player_hand.add_child(card)
		card.card_clicked.connect(_on_card_clicked)


func get_enemy_pool() -> Array[String]:
	match RunManager.current_combat_type:
		"elite":
			return elite_enemy_pool
		"boss":
			return boss_enemy_pool
		_:
			return normal_enemy_pool


func create_enemy_hand() -> void:
	for child: Node in opponent_hand.get_children():
		child.queue_free()
	var pool: Array[String] = get_enemy_pool()
	var shuffled_pool: Array[String] = pool.duplicate()
	shuffled_pool.shuffle()
	var cards_to_create: int = mini(5, shuffled_pool.size())
	for i: int in range(cards_to_create):
		var card_path: String = shuffled_pool[i]
		var resource: Resource = load(card_path)
		if resource is CardData:
			var card_data: CardData = resource as CardData
			var card: GameCard = CARD_SCENE.instantiate() as GameCard
			card.data = card_data
			card.set_card_owner(COMPUTER)
			opponent_hand.add_child(card)


func update_scores() -> void:
	var player_score: int = 0
	var computer_score: int = 0
	for card in board:
		if card == null:
			continue
		var game_card: GameCard = card as GameCard
		if game_card == null:
			continue
		if game_card.owner_id == PLAYER:
			player_score += 1
		elif game_card.owner_id == COMPUTER:
			computer_score += 1
	for child: Node in player_hand.get_children():
		if child is GameCard:
			player_score += 1
	for child: Node in opponent_hand.get_children():
		if child is GameCard:
			computer_score += 1
	player_score_label.text = "Player: " + str(player_score)
	enemy_score_label.text = "Enemy: " + str(computer_score)


func resolve_combat(player_score: int, computer_score: int) -> void:
	game_over = true
	if player_score > computer_score:
		handle_combat_win()
	elif computer_score > player_score:
		handle_combat_loss(player_score, computer_score)
	else:
		handle_combat_draw()


func handle_combat_win() -> void:
	var encounter_complete: bool = RunManager.add_encounter_win()
	update_encounter_progress()
	RunManager.consume_combat_buffs()
	if encounter_complete:
		handle_encounter_complete()
		return
	match RunManager.current_combat_type:
		"elite":
			result_label.text = ("Victory!\n" + "Elite Wins: " + str(RunManager.encounter_wins) + " / " + str(RunManager.encounter_wins_required))
		"boss":
			result_label.text = ("Victory!\n" + "Boss Wins: " + str(RunManager.encounter_wins) + " / " + str(RunManager.encounter_wins_required))
		_:
			result_label.text = "Victory!"
	continue_button.text = "Next Match"
	continue_button.show()


func handle_combat_loss(_player_score: int, _computer_score: int) -> void:
	RunManager.consume_combat_buffs()
	RunManager.player_health -= 1
	RunManager.player_health = maxi(RunManager.player_health, 0)
	update_health_display()
	update_encounter_progress()
	if RunManager.player_health <= 0:
		handle_run_defeat()
		return
	match RunManager.current_combat_type:
		"boss":
			result_label.text = ("Boss Match Lost!\n" + "Lost 1 Health\n" + "Boss Wins: " + str(RunManager.encounter_wins) + " / 3")
		"elite":
			result_label.text = ("Elite Match Lost!\n" + "Lost 1 Health\n" + "Elite Wins: " + str(RunManager.encounter_wins) + " / 2")
		_:
			result_label.text = ("Defeat!\nLost 1 Health")
	continue_button.text = "Try Again"
	continue_button.show()


func handle_combat_draw() -> void:
	result_label.text = "Draw!"
	continue_button.text = "Try Again"
	continue_button.show()


func handle_run_defeat() -> void:
	run_defeated = true
	result_label.text = "Run Over"
	RunManager.player_defeated()
	continue_button.text = "Game Over"
	continue_button.show()


func update_encounter_progress() -> void:
	encounter_progress_label.text = ("Wins: " + str(RunManager.encounter_wins) + " / " + str(RunManager.encounter_wins_required))


func handle_encounter_complete() -> void:
	match RunManager.current_combat_type:
		"elite":
			result_label.text = "Elite Defeated!"
		"boss":
			result_label.text = "Boss Defeated!"
		_:
			result_label.text = "Victory!"
	RunManager.complete_selected_room()
	RunManager.clear_encounter_progress()
	RunManager.clear_battle_hand()
	continue_button.text = "Return to Map"
	continue_button.show()


func setup_combat_buffs() -> void:
	combat_buff_value_bonus = 0
	enemy_combat_value_bonus = 0
	if RunManager.has_combat_buff("extra_card_power"):
		combat_buff_value_bonus = 1
	if RunManager.has_combat_buff("weakening_curse"):
		enemy_combat_value_bonus = -1
	print("Player combat bonus: ", combat_buff_value_bonus)
	print("Enemy combat bonus: ", enemy_combat_value_bonus)


















#
