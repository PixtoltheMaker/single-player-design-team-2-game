extends Control

const PLAYER := 0
const COMPUTER := 1

enum AIDifficulty {
	NORMAL,
	MEDIUM,
	HARD
}

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
@onready var turn_label: Label = $UI/TurnLabel
@onready var player_score_label: Label = $UI/PlayerScore
@onready var enemy_score_label: Label = $UI/EnemyScore
@onready var result_label: Label = $UI/ResultLabel
@onready var difficulty_panel: PanelContainer = $UI/DifficultyPanel
@onready var difficulty_label: Label = $UI/DifficultyPanel/VBoxContainer/DifficultyLabel

var current_player: int = PLAYER
var selected_card: GameCard = null
var game_over: bool = false


func _ready() -> void:
	# Connect board slots.
	for slot in board_container.get_children():
		if slot is BoardSlot:
			slot.slot_clicked.connect(_on_slot_clicked)
	# Set up player cards.
	for card in player_hand.get_children():
		if card is GameCard:
			card.set_card_owner(PLAYER)
			card.card_clicked.connect(_on_card_clicked)
	# Set up computer cards.
	for card in opponent_hand.get_children():
		if card is GameCard:
			card.set_card_owner(COMPUTER)
	update_turn_label()
	update_score()


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
	if not difficulty_selected:
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
	card.board_position = Vector2i(index % 3, index / 3)
	card.reparent(slot)
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.position = Vector2.ZERO
	check_captures(card)
	update_score()
	print(card.data.card_name, " placed in slot ", index)


func get_card_at(position: Vector2i) -> GameCard:
	if position.x < 0 or position.x >= 3:
		return null
	if position.y < 0 or position.y >= 3:
		return null
	var index := position.y * 3 + position.x
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
	var attack_value: int
	var defense_value: int
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
	if attack_value > defense_value:
		capture_card(enemy, card.owner_id)


func capture_card(card: GameCard, new_owner: int) -> void:
	card.set_card_owner(new_owner)
	print(card.data.card_name, " was captured!")


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
	game_over = true
	update_score()
	var scores := get_scores()
	if scores[0] > scores[1]:
		result_label.text = "YOU WIN!"
	elif scores[1] > scores[0]:
		result_label.text = "COMPUTER WINS!"
	else:
		result_label.text = "DRAW!"
	turn_label.text = "Game Over"


func evaluate_move(card: GameCard, slot: BoardSlot) -> int:
	var score: int = 0
	var index := slot.slot_index
	var position := Vector2i(index % 3, index / 3)
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


func is_corner(position: Vector2i) -> bool:
	return (
		position == Vector2i(0, 0)
		or position == Vector2i(2, 0)
		or position == Vector2i(0, 2)
		or position == Vector2i(2, 2)
	)


func evaluate_danger(
	card: GameCard,
	position: Vector2i
) -> int:
	var danger: int = 0
	if position.y > 0:
		if get_card_at(position + Vector2i.UP) == null:
			danger += get_side_threat(card.data.up, "down")
	if position.x < 2:
		if get_card_at(position + Vector2i.RIGHT) == null:
			danger += get_side_threat(card.data.right, "left")
	if position.y < 2:
		if get_card_at(position + Vector2i.DOWN) == null:
			danger += get_side_threat(card.data.down, "up")
	if position.x > 0:
		if get_card_at(position + Vector2i.LEFT) == null:
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


func _on_normal_pressed() -> void:
	set_ai_difficulty(AIDifficulty.NORMAL)


func _on_medium_pressed() -> void:
	set_ai_difficulty(AIDifficulty.MEDIUM)


func _on_hard_pressed() -> void:
	set_ai_difficulty(AIDifficulty.HARD)


func set_ai_difficulty(difficulty: AIDifficulty) -> void:
	ai_difficulty = difficulty
	difficulty_selected = true
	match ai_difficulty:
		AIDifficulty.NORMAL:
			print("AI Difficulty: Normal")
		AIDifficulty.MEDIUM:
			print("AI Difficulty: Medium")
		AIDifficulty.HARD:
			print("AI Difficulty: Hard")
	difficulty_panel.hide()
	update_turn_label()


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
	var position := Vector2i(slot.slot_index % 3, slot.slot_index / 3)
	if position.y > 0:
		if get_card_at(position + Vector2i.UP) == null:
			score -= get_side_threat(card.data.up, "down")
	if position.x < 2:
		if get_card_at(position + Vector2i.RIGHT) == null:
			score -= get_side_threat(card.data.right, "left")
	if position.y < 2:
		if get_card_at(position + Vector2i.DOWN) == null:
			score -= get_side_threat(card.data.down, "up")
	if position.x > 0:
		if get_card_at(position + Vector2i.LEFT) == null:
			score -= get_side_threat(card.data.left, "right")
	return score








#
