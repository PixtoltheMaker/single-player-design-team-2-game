class_name CardVariantGenerator
extends RefCounted


static func create_variant(card_path: String, rarity: CardData.Rarity) -> CardData:
	var original_card: CardData = load(card_path) as CardData
	if original_card == null:
		return null
	var card: CardData = original_card.duplicate() as CardData
	card.rarity = rarity
	match rarity:
		CardData.Rarity.NORMAL:
			pass
		CardData.Rarity.RARE:
			card.up = mini(card.up + 1, 10)
			card.right = mini(card.right + 1, 10)
			card.down = mini(card.down + 1, 10)
			card.left = mini(card.left + 1, 10)
			apply_rare_ability(card, card_path)
		CardData.Rarity.MYTHIC:
			card.up = mini(card.up + 2, 10)
			card.right = mini(card.right + 2, 10)
			card.down = mini(card.down + 2, 10)
			card.left = mini(card.left + 2, 10)
			apply_mythic_ability(card)
	return card


static func apply_mythic_ability(card: CardData) -> void:
	var abilities: Array[Dictionary] = [
		{
			"id": "Dragon_Fury",
			"description": "Gain +2 attack when capturing an enemy card."
		},
		{
			"id": "Blood_Hunt",
			"description": "Gain +1 attack against powerful enemy cards."
		},
		{
			"id": "Petrify",
			"description": "The first card captured by this card cannot recapture."
		},
		{
			"id": "Divine_Shield",
			"description": "Survive the first capture against this card."
		}
	]
	var ability: Dictionary = abilities.pick_random()
	card.mythic_ability = str(ability["id"])
	card.mythic_description = str(ability["description"])


static func apply_rare_ability(card: CardData, card_path: String) -> void:
	var path := card_path.to_lower()
	var ability := {}
	if "/vermin/" in path:
		ability = {"id": "Swarm Tactics", "description": "+1 attack when another friendly card is orthogonally adjacent."}
	elif "/undead/" in path:
		ability = {"id": "Deathless Return", "description": "Resist the first capture attempt against this card each battle."}
	elif "/plants/" in path:
		ability = {"id": "Entangling Vines", "description": "+1 attack when attacking an enemy card."}
	elif "/outsider/" in path:
		ability = {"id": "Planar Shift", "description": "+1 defense on every side."}
	elif "/monstrosity/" in path:
		ability = {"id": "Savage Instinct", "description": "+1 attack for each adjacent enemy, up to +2."}
	elif "/humanoid/" in path:
		ability = {"id": "Tactical Formation", "description": "+1 defense on sides facing friendly cards."}
	elif "/dragons/" in path:
		ability = {"id": "Dragon Roar", "description": "+1 attack against enemies with a side value of 8 or higher."}
	elif "/aberrations/" in path:
		ability = {"id": "Mind Warp", "description": "+1 defense against attacks."}
	if not ability.is_empty():
		card.rare_ability = str(ability["id"])
		card.rare_description = str(ability["description"])
