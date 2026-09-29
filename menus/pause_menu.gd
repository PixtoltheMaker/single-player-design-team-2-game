extends Control


@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var return_to_map_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ReturnToMapButton
@onready var main_menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton


var is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	return_to_map_button.pressed.connect(_on_return_to_map_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	is_paused = true
	show()
	get_tree().paused = true


func resume_game() -> void:
	is_paused = false
	hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	resume_game()


func _on_settings_pressed() -> void:
	print("Settings menu opened")


func _on_return_to_map_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	RunManager.clear_battle_hand()
	RunManager.clear_encounter_progress()
	get_tree().change_scene_to_file("res://GameManager/Map/run_map.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	is_paused = false
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")
