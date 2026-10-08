extends Control

enum RunLength {
	SHORT,
	STANDARD,
	LONG
}

@onready var easy_button: Button = $CenterContainer/Panel/VBoxContainer/EasyButton
@onready var normal_button: Button = $CenterContainer/Panel/VBoxContainer/NormalButton
@onready var hard_button: Button = $CenterContainer/Panel/VBoxContainer/HardButton
@onready var run_info_label: Label = $CenterContainer/Panel/VBoxContainer/RunInfoLabel
@onready var start_button: Button = $CenterContainer/Panel/VBoxContainer/StartButton
@onready var back_button: Button = $CenterContainer/Panel/VBoxContainer/BackButton
@onready var tutorial_button: Button = $CenterContainer/Panel/VBoxContainer/TutorialButton

var selected_run_length: RunLength = RunLength.STANDARD

var selected_encounters: int = 12
var selected_bosses: int = 2


func _ready() -> void:
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	update_difficulty_buttons()


func select_easy() -> void:
	selected_run_length = RunLength.SHORT
	selected_encounters = 8
	selected_bosses = 1
	run_info_label.text = ("SHORT RUN\n\n" + "Rooms: 12\n" + "Bosses: 1")
	update_button_states()


func select_normal() -> void:
	selected_run_length = RunLength.STANDARD
	selected_encounters = 12
	selected_bosses = 2
	run_info_label.text = ("STANDARD RUN\n\n" + "Rooms: 24\n" + "Bosses: 2")
	update_button_states()


func select_hard() -> void:
	selected_run_length = RunLength.LONG
	selected_encounters = 18
	selected_bosses = 3
	run_info_label.text = ("LONG RUN\n\n" + "Rooms: 36\n" + "Bosses: 3")
	update_button_states()


func update_button_states() -> void:
	easy_button.text = "SHORT RUN"
	normal_button.text = "STANDARD RUN"
	hard_button.text = "LONG RUN"
	match selected_run_length:
		RunLength.SHORT:
			easy_button.text = "> SHORT RUN <"
		RunLength.STANDARD:
			normal_button.text = "> STANDARD RUN <"
		RunLength.LONG:
			hard_button.text = "> LONG RUN <"


func _on_easy_button_pressed() -> void:
	select_easy()


func _on_normal_button_pressed() -> void:
	normal_button.disabled = not RunManager.is_difficulty_unlocked("normal")
	select_normal()


func _on_hard_button_pressed() -> void:
	hard_button.disabled = not RunManager.is_difficulty_unlocked("hard")
	select_hard()


func _on_start_button_pressed() -> void:
	RunManager.run_encounter_count = selected_encounters
	RunManager.run_boss_count = selected_bosses
	RunManager.start_new_run()
	get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")


func update_difficulty_buttons() -> void:
	if RunManager.is_difficulty_unlocked("normal"):
		normal_button.text = "NORMAL"
		normal_button.disabled = false
	else:
		normal_button.text = "NORMAL\n🔒 Beat Easy to unlock"
		normal_button.disabled = true

	if RunManager.is_difficulty_unlocked("hard"):
		hard_button.text = "HARD"
		hard_button.disabled = false
	else:
		hard_button.text = "HARD\n🔒 Beat Normal to unlock"
		hard_button.disabled = true


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/Tutorial.tscn")
