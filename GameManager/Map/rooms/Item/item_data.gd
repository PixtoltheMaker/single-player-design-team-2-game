class_name ItemData
extends Resource

enum ItemType {
	WEAPON,
	ARMOR,
	BONUS_REWARD,
	SUPPORT
}

@export_category("Item Information")
@export var item_name: String = "Item"
@export_multiline var description: String = ""
@export var icon: Texture2D


@export_category("Item Settings")
@export var item_type: ItemType = ItemType.WEAPON
@export var value: int = 0
