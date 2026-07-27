extends Node

var death_penalty: Dictionary = {}

func _ready():
	death_penalty = {
		"pve": {
			"experience_loss": 0.05,
			"durability_loss": 0.1,
			"level_loss": false
		},
		"pvp_white": {
			"experience_loss": 0,
			"durability_loss": 0,
			"level_loss": false
		},
		"pvp_red": {
			"experience_loss": 0.1,
			"durability_loss": 0.3,
			"level_loss": true,
			"item_drop": true
		}
	}

func on_death(character: Node, killer: Node = null):
	var death_type: String = determine_death_type(character, killer)
	var penalty: Dictionary = death_penalty.get(death_type, death_penalty["pve"])
	
	if character.has_node("LevelSystem"):
		var level_system: LevelSystem = character.get_node("LevelSystem")
		if penalty["experience_loss"] > 0:
			var current_exp: float = level_system.current_experience
			var loss: float = current_exp * penalty["experience_loss"]
			level_system.current_experience = max(0, current_exp - loss)
		
		if penalty["level_loss"] and level_system.current_level > 1:
			level_system.current_level -= 1
	
	if character.has_node("EquipmentManager"):
		var equipment_manager: EquipmentManager = character.get_node("EquipmentManager")
		if penalty["durability_loss"] > 0:
			equipment_manager.reduce_all_durability(penalty["durability_loss"])
		
		if penalty.get("item_drop", false):
			equipment_manager.drop_random_items(3)
	
	EventBus.emit_death(character, killer)

func determine_death_type(character: Node, killer: Node) -> String:
	if not killer:
		return "pve"
	
	if killer.is_in_group("players"):
		var pk_system: PKSystem = get_node_or_null("/root/PKSystem")
		if pk_system and pk_system.is_red_name(killer):
			return "pvp_red"
		return "pvp_white"
	
	return "pve"

func revive(character: Node, revive_type: String = "normal"):
	match revive_type:
		"normal":
			normal_revive(character)
		"instant":
			instant_revive(character)
		"party":
			party_revive(character)
		"resurrection":
			resurrection_revive(character)
	
	EventBus.emit_revive(character)

func normal_revive(character: Node):
	if character.has_node("CharacterStats"):
		var stats: CharacterStats = character.get_node("CharacterStats")
		stats.set_base_stat("hp", stats.get_stat("hp") * 0.3)
		stats.set_base_stat("mp", stats.get_stat("mp") * 0.3)
	
	if character.has_method("on_revive"):
		character.on_revive()

func instant_revive(character: Node):
	if character.has_node("CharacterStats"):
		var stats: CharacterStats = character.get_node("CharacterStats")
		stats.set_base_stat("hp", stats.get_stat("hp"))
		stats.set_base_stat("mp", stats.get_stat("mp"))
	
	if character.has_method("on_revive"):
		character.on_revive()

func party_revive(character: Node):
	if character.has_node("CharacterStats"):
		var stats: CharacterStats = character.get_node("CharacterStats")
		stats.set_base_stat("hp", stats.get_stat("hp") * 0.7)
		stats.set_base_stat("mp", stats.get_stat("mp") * 0.7)
	
	if character.has_method("on_revive"):
		character.on_revive()

func resurrection_revive(character: Node):
	instant_revive(character)
