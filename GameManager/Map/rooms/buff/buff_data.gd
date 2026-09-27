class_name BuffData
extends Resource

enum BuffType {
	CARD_BONUS_ATTACK,
	CARD_BONUS_DEFENCE,
	ELITE_REWARD,
	HEAL_AFTER_COMBAT
}

@export_category("Buff Information")
@export var buff_name: String = "Buff"
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_category("Buff Settings")
@export var buff_type: BuffType = BuffType.CARD_BONUS_ATTACK
@export var value: int = 0
