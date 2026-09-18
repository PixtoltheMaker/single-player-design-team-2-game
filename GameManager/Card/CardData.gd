class_name CardData
extends Resource

@export_category("Card Information")
@export var card_name: String = "Card"
@export var artwork: Texture2D

@export_category("Card Values")
@export_range(1, 10) var up: int = 1
@export_range(1, 10) var right: int = 1
@export_range(1, 10) var down: int = 1
@export_range(1, 10) var left: int = 1
