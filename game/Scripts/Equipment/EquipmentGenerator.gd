extends Node

var equipment_templates: Dictionary = {}

func _ready():
	load_templates()

func load_templates():
	equipment_templates = {
		"weapon": {
			"common_sword": {
				"name": "普通剑",
				"slot_type": EquipmentData.SlotType.WEAPON,
				"base_stats": {"attack": 10}
			},
			"iron_sword": {
				"name": "铁剑",
				"slot_type": EquipmentData.SlotType.WEAPON,
				"base_stats": {"attack": 25}
			},
			"bronze_sword": {
				"name": "青铜剑",
				"slot_type": EquipmentData.SlotType.WEAPON,
				"base_stats": {"attack": 40}
			},
			"silver_sword": {
				"name": "银剑",
				"slot_type": EquipmentData.SlotType.WEAPON,
				"base_stats": {"attack": 60}
			},
			"gold_sword": {
				"name": "金剑",
				"slot_type": EquipmentData.SlotType.WEAPON,
				"base_stats": {"attack": 90}
			}
		},
		"armor": {
			"common_armor": {
				"name": "普通铠甲",
				"slot_type": EquipmentData.SlotType.ARMOR,
				"base_stats": {"armor": 10, "hp": 50}
			},
			"iron_armor": {
				"name": "铁甲",
				"slot_type": EquipmentData.SlotType.ARMOR,
				"base_stats": {"armor": 25, "hp": 120}
			},
			"bronze_armor": {
				"name": "青铜甲",
				"slot_type": EquipmentData.SlotType.ARMOR,
				"base_stats": {"armor": 40, "hp": 200}
			}
		},
		"shoes": {
			"common_shoes": {
				"name": "普通鞋",
				"slot_type": EquipmentData.SlotType.SHOES,
				"base_stats": {"move_speed": 0.2}
			},
			"iron_shoes": {
				"name": "铁靴",
				"slot_type": EquipmentData.SlotType.SHOES,
				"base_stats": {"move_speed": 0.5, "armor": 5}
			}
		}
	}

func generate_equipment(level: int, rarity: int = -1) -> EquipmentData:
	var slot_type: int = rand_range(0, 10)
	var slot_key: String = get_slot_key(slot_type)
	
	if slot_key not in equipment_templates:
		return null
	
	var templates: Dictionary = equipment_templates[slot_key]
	var template_keys: Array = []
	for key in templates:
		template_keys.append(key)
	
	var random_template: String = template_keys[rand_range(0, len(template_keys))]
	var template: Dictionary = templates[random_template]
	
	var final_rarity: int = rarity if rarity >= 0 else roll_rarity(level)
	
	var equipment: EquipmentData = EquipmentData.new()
	equipment.id = random_template + "_" + str(level) + "_" + str(randi())
	equipment.name = template["name"]
	equipment.slot_type = template["slot_type"]
	equipment.rarity = final_rarity
	equipment.level_requirement = level
	equipment.base_stats = {}
	
	for stat_name in template["base_stats"]:
		var base_value: float = template["base_stats"][stat_name]
		var level_multiplier: float = 1 + (level - 1) * 0.1
		var rarity_multiplier: float = RaritySystem.get_rarity_multiplier(final_rarity)
		equipment.base_stats[stat_name] = int(base_value * level_multiplier * rarity_multiplier)
	
	equipment.max_durability = 100 + final_rarity * 20
	equipment.durability = equipment.max_durability
	equipment.wear_resistance = 1.0 + final_rarity * 0.1
	
	roll_special_effects(equipment, final_rarity)
	
	return equipment

func roll_rarity(level: int) -> int:
	var weights: Array = [
		{"rarity": RaritySystem.Rarity.COMMON, "weight": 40},
		{"rarity": RaritySystem.Rarity.ELITE, "weight": 25},
		{"rarity": RaritySystem.Rarity.IRON, "weight": 15},
		{"rarity": RaritySystem.Rarity.BRONZE, "weight": 10},
		{"rarity": RaritySystem.Rarity.SILVER, "weight": 5},
		{"rarity": RaritySystem.Rarity.GOLD, "weight": 3},
		{"rarity": RaritySystem.Rarity.PLATINUM, "weight": 1},
		{"rarity": RaritySystem.Rarity.DIAMOND, "weight": 0.5},
		{"rarity": RaritySystem.Rarity.STARLIGHT, "weight": 0.3},
		{"rarity": RaritySystem.Rarity.GRANDMASTER, "weight": 0.15},
		{"rarity": RaritySystem.Rarity.KING, "weight": 0.03},
		{"rarity": RaritySystem.Rarity.EMPEROR, "weight": 0.01},
		{"rarity": RaritySystem.Rarity.GOD, "weight": 0.005}
	]
	
	var level_bonus: float = level * 0.5
	for w in weights:
		w["weight"] *= (1 + level_bonus / 100)
	
	var total_weight: float = 0
	for w in weights:
		total_weight += w["weight"]
	
	var random: float = rand_range(0, total_weight)
	var cumulative: float = 0
	
	for w in weights:
		cumulative += w["weight"]
		if random <= cumulative:
			return w["rarity"]
	
	return RaritySystem.Rarity.COMMON

func roll_special_effects(equipment: EquipmentData, rarity: int):
	var rarity_data: Dictionary = RaritySystem.get_rarity_data(rarity)
	var extra_stats_count: int = rarity_data["extra_stats"]
	var effect_chance: float = rarity_data["special_effect_chance"]
	
	for i in range(extra_stats_count):
		var stat: String = get_random_stat()
		var value: float = get_random_stat_value(rarity)
		equipment.base_stats[stat] = equipment.base_stats.get(stat, 0) + value
	
	if randf() < effect_chance:
		var special_effect: String = get_random_special_effect()
		equipment.special_effects.append(special_effect)

func get_random_stat() -> String:
	var stats: Array = ["attack", "magic_power", "armor", "magic_resist", "attack_speed", "move_speed", "crit_rate", "crit_damage", "lifesteal", "tenacity"]
	return stats[rand_range(0, len(stats))]

func get_random_stat_value(rarity: int) -> float:
	var base_value: float = 5 + rarity * 2
	return int(base_value * (1 + rand_range(0, 0.5)))

func get_random_special_effect() -> String:
	var effects: Array = ["lifesteal", "thorns", "true_damage", "magic_penetration", "physical_penetration", "crowd_control_resist"]
	return effects[rand_range(0, len(effects))]

func get_slot_key(slot_type: int) -> String:
	var slot_map: Dictionary = {
		EquipmentData.SlotType.WEAPON: "weapon",
		EquipmentData.SlotType.SHOES: "shoes",
		EquipmentData.SlotType.HEART_MIRROR: "weapon",
		EquipmentData.SlotType.ARMOR: "armor",
		EquipmentData.SlotType.HELMET: "armor",
		EquipmentData.SlotType.CLOAK: "armor",
		EquipmentData.SlotType.RING: "weapon",
		EquipmentData.SlotType.NECKLACE: "weapon",
		EquipmentData.SlotType.SHOULDER: "armor",
		EquipmentData.SlotType.LEGGINGS: "armor"
	}
	return slot_map.get(slot_type, "weapon")
