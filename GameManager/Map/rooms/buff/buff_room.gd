extends Control

@onready var buff_choices: HBoxContainer = $BuffChoices

var buff_pool: Array[String] = [
	
	
	
	
	
	
	
	
]

var offered_buffs: Array[BuffData] = []
var offered_buff_paths: Array[String] = []


func _ready() -> void:
	generate_buff_choices()


func generate_buff_choices() -> void:
	offered_buffs.clear()
	offered_buff_paths.clear()
	var available_pool: Array[String] = buff_pool.duplicate()
	available_pool.shuffle()
	var amount: int = mini(3, available_pool.size())
	for i: int in range(amount):
		var buff_path: String = available_pool[i]
		var resource: Resource = load(buff_path)
		if resource is BuffData:
			var buff: BuffData = resource as BuffData
			offered_buffs.append(buff)
			offered_buff_paths.append(buff_path)
	create_buff_buttons()


func create_buff_buttons() -> void:
	for child: Node in buff_choices.get_children():
		child.queue_free()
	for i: int in range(offered_buffs.size()):
		var buff: BuffData = offered_buffs[i]
		var container := VBoxContainer.new()
		container.custom_minimum_size = Vector2(220, 250)
		buff_choices.add_child(container)
		var name_label := Label.new()
		name_label.text = buff.buff_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(name_label)
		var icon_rect := TextureRect.new()
		icon_rect.texture = buff.icon
		icon_rect.custom_minimum_size = Vector2(128, 128)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = \
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		container.add_child(icon_rect)
		var description := Label.new()
		description.text = buff.description
		description.autowrap_mode = \
			TextServer.AUTOWRAP_WORD_SMART
		container.add_child(description)
		var choose_button := Button.new()
		choose_button.text = "Choose"
		choose_button.pressed.connect(_on_buff_chosen.bind(i))
		container.add_child(choose_button)


func _on_buff_chosen(index: int) -> void:
	if index < 0:
		return
	if index >= offered_buff_paths.size():
		return
	var buff_path: String = offered_buff_paths[index]
	var buff: BuffData = offered_buffs[index]
	print("Selected buff: ", buff.buff_name)
	RunManager.add_buff(buff_path)
	finish_buff_room()


func finish_buff_room() -> void:
	RunManager.complete_selected_room()
	get_tree().change_scene_to_file("res://GameManager/map/RunMap.tscn")


func _on_skip_button_pressed() -> void:
	finish_buff_room()















































#
