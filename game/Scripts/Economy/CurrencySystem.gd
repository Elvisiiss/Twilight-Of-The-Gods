extends Node

var gold: int = 0
var diamonds: int = 0
var soul_crystals: int = 0
var reputation: int = 0

func _ready():
	pass

func add_gold(amount: int):
	gold += amount
	EventBus.emit_currency_change("gold", gold)

func remove_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		EventBus.emit_currency_change("gold", gold)
		return true
	return false

func add_diamonds(amount: int):
	diamonds += amount
	EventBus.emit_currency_change("diamonds", diamonds)

func remove_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
		EventBus.emit_currency_change("diamonds", diamonds)
		return true
	return false

func add_soul_crystals(amount: int):
	soul_crystals += amount
	EventBus.emit_currency_change("soul_crystals", soul_crystals)

func remove_soul_crystals(amount: int) -> bool:
	if soul_crystals >= amount:
		soul_crystals -= amount
		EventBus.emit_currency_change("soul_crystals", soul_crystals)
		return true
	return false

func add_reputation(amount: int):
	reputation += amount
	EventBus.emit_currency_change("reputation", reputation)

func remove_reputation(amount: int) -> bool:
	if reputation >= amount:
		reputation -= amount
		EventBus.emit_currency_change("reputation", reputation)
		return true
	return false

func can_afford(cost: Dictionary) -> bool:
	if cost.get("gold", 0) > gold:
		return false
	if cost.get("diamonds", 0) > diamonds:
		return false
	if cost.get("soul_crystals", 0) > soul_crystals:
		return false
	if cost.get("reputation", 0) > reputation:
		return false
	return true

func pay_cost(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	
	remove_gold(cost.get("gold", 0))
	remove_diamonds(cost.get("diamonds", 0))
	remove_soul_crystals(cost.get("soul_crystals", 0))
	remove_reputation(cost.get("reputation", 0))
	
	return true

func get_balance() -> Dictionary:
	return {
		"gold": gold,
		"diamonds": diamonds,
		"soul_crystals": soul_crystals,
		"reputation": reputation
	}
