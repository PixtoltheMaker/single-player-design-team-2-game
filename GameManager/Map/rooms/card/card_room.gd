extends Control

@onready var card_choices: HBoxContainer = $CardChoices
@onready var description_label: Label = $DescriptionLabel
@onready var skip_button: Button = $SkipButton

const CARD_SCENE: PackedScene = preload("res://GameManager/Card/card.tscn")

var card_pool: Array[String] = [
	"res://GameManager/Card/Type/vermin/Birds.tres",
	"res://GameManager/Card/Type/vermin/Insects.tres",
	"res://GameManager/Card/Type/vermin/Rats.tres",
	"res://GameManager/Card/Type/vermin/Squirrel.tres",
	"res://GameManager/Card/Type/undead/Skeleton(Armored).tres",
	"res://GameManager/Card/Type/undead/Skeleton(Normal).tres",
	"res://GameManager/Card/Type/undead/Zombie.tres",
	"res://GameManager/Card/Type/plants/Mandrake.tres",
	"res://GameManager/Card/Type/plants/Pincher.tres",
	"res://GameManager/Card/Type/plants/Trap.tres",
	"res://GameManager/Card/Type/outsider/Angel.tres",
	"res://GameManager/Card/Type/outsider/Devil.tres",
	"res://GameManager/Card/Type/outsider/Fiend.tres",
	"res://GameManager/Card/Type/monstrosity/Bulette.tres",
	"res://GameManager/Card/Type/monstrosity/Gorgon.tres",
	"res://GameManager/Card/Type/monstrosity/Hydra.tres",
	"res://GameManager/Card/Type/monstrosity/Manticore.tres",
	"res://GameManager/Card/Type/humanoid/Dwarf.tres",
	"res://GameManager/Card/Type/humanoid/Elf(high).tres",
	"res://GameManager/Card/Type/humanoid/Elf(wild).tres",
	"res://GameManager/Card/Type/humanoid/Human.tres",
	"res://GameManager/Card/Type/dragons/BlackDragon.tres",
	"res://GameManager/Card/Type/dragons/BlueDragon.tres",
	"res://GameManager/Card/Type/dragons/GreenDragon.tres",
	"res://GameManager/Card/Type/dragons/RedDragon.tres",
	"res://GameManager/Card/Type/aberrations/Abalith.tres",
	"res://GameManager/Card/Type/aberrations/EyeGaser.tres",
	"res://GameManager/Card/Type/aberrations/Ropper.tres"
]

var offered_cards: Array[CardData] = []
var choice_buttons: Array[Button] = []
var offered_card_paths: Array[String] = []


func _ready() -> void:
	generate_card_choices()


func generate_card_choices() -> void:
	offered_cards.clear()
	offered_card_paths.clear()
	var available_pool := card_pool.duplicate()
	available_pool.shuffle()
	var amount: int = min(3, available_pool.size())
	for i in range(amount):
		var card_path: String = available_pool[i]
		var card_data: CardData = load(card_path)
		if card_data != null:
			offered_cards.append(card_data)
			offered_card_paths.append(card_path)
	create_choice_buttons()

func create_choice_buttons() -> void:
	for child in card_choices.get_children():
		child.queue_free()
	choice_buttons.clear()
	for i in range(offered_cards.size()):
		var card_data := offered_cards[i]
		var container := VBoxContainer.new()
		card_choices.add_child(container)
		var card: GameCard = CARD_SCENE.instantiate()
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.data = card_data
		container.add_child(card)
		var choose_button := Button.new()
		choose_button.text = "Choose"
		container.add_child(choose_button)
		choose_button.pressed.connect(_on_card_chosen.bind(i))
		choice_buttons.append(choose_button)


func _on_card_chosen(index: int) -> void:
	if index < 0:
		return
	if index >= offered_card_paths.size():
		return
	var selected_path: String = offered_card_paths[index]
	var selected_card: CardData = offered_cards[index]
	print("Selected card: ", selected_card.card_name)
	RunManager.player_cards.append(selected_path)
	RunManager.unlock_card(selected_path)
	finish_card_room()


func finish_card_room() -> void:
	RunManager.complete_selected_room()
	get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")


func _on_skip_button_pressed() -> void:
	print("Player skipped card reward.")
	finish_card_room()




























#
