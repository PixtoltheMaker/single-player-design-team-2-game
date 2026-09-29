extends Control


@onready var reason_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ReasonLabel
@onready var run_summary_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RunSummaryLabel
@onready var retry_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()


func show_game_over(reason: String = "Your run has ended.") -> void:
	get_tree().paused = true
	reason_label.text = reason
	var summary: String = "Run Complete"
	if RunManager.player_health <= 0:
		summary = "You ran out of health."
	run_summary_label.text = summary
	show()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	RunManager.start_new_run()
	get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")
