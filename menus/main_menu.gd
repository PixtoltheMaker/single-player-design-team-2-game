extends Control

@onready var new_run_button: Button = $MenuPanel/VBoxContainer/NewRunButton
@onready var continue_button: Button = $MenuPanel/VBoxContainer/ContinueButton
@onready var collection_button: Button = $MenuPanel/VBoxContainer/CollectionButton
@onready var options_button: Button = $MenuPanel/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton


func _ready() -> void:
	update_continue_button()


func update_continue_button() -> void:
	continue_button.disabled = not RunManager.run_active


func _on_new_run_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/PreRun.tscn")


func _on_continue_button_pressed() -> void:
	if not RunManager.run_active:
		return
	get_tree().change_scene_to_file("res://GameManager/Map/RunMap.tscn")


func _on_collection_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/card_collection.tscn")


func _on_options_button_pressed() -> void:
	print("Options coming soon.")


func _on_quit_button_pressed() -> void:
	get_tree().quit()



















































































#
