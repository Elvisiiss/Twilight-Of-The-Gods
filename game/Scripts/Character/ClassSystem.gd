extends Node

var classes: Dictionary = {}
var current_class: String = ""
var current_turn: int = 0
var quality_rank: String = "Starlight"

func _ready():
	load_base_classes()

func load_base_classes():
	classes = {
		"archer": ClassData.from_dict({
			"id": "archer",
			"name": "弓箭手",
			"description": "远程物理DPS，持续输出核心，攻速成长翻倍",
			"stat_multipliers": {
				"attack": 2.0,
				"attack_speed": 2.0,
				"crit_rate": 2.0
			},
			"attribute_bonus": {
				"hp": 10,
				"mp": 5,
				"attack": 4,
				"attack_speed": 0.02,
				"crit_rate": 0.01
			},
			"primary_attributes": ["attack", "attack_speed", "crit_rate"],
			"secondary_attributes": ["move_speed"],
			"skills": ["normal_shot", "five_arrows", "thunder_jump"],
			"tier": 1
		}),
		"warrior": ClassData.from_dict({
			"id": "warrior",
			"name": "战士",
			"description": "坦克/近战，HP成长翻倍，双抗翻倍",
			"stat_multipliers": {
				"hp": 2.0,
				"armor": 2.0,
				"magic_resist": 2.0
			},
			"attribute_bonus": {
				"hp": 20,
				"mp": 5,
				"attack": 2,
				"armor": 3,
				"magic_resist": 3
			},
			"primary_attributes": ["hp", "armor", "magic_resist"],
			"secondary_attributes": ["attack"],
			"skills": ["double_shield", "double_armor", "double_slash"],
			"tier": 1
		}),
		"assassin": ClassData.from_dict({
			"id": "assassin",
			"name": "刺客",
			"description": "近战爆发/高机动，攻击/移速/暴击翻倍",
			"stat_multipliers": {
				"attack": 2.0,
				"move_speed": 2.0,
				"crit_rate": 2.0
			},
			"attribute_bonus": {
				"hp": 10,
				"mp": 5,
				"attack": 4,
				"move_speed": 0.2,
				"crit_rate": 0.01
			},
			"primary_attributes": ["attack", "move_speed", "crit_rate"],
			"secondary_attributes": ["attack_speed"],
			"skills": ["stealth", "backstab", "shadow_step"],
			"tier": 1
		}),
		"mage": ClassData.from_dict({
			"id": "mage",
			"name": "法师",
			"description": "远程魔法AoE，法强/蓝量/移速翻倍",
			"stat_multipliers": {
				"magic_power": 2.0,
				"mp": 2.0,
				"move_speed": 2.0
			},
			"attribute_bonus": {
				"hp": 10,
				"mp": 20,
				"magic_power": 4,
				"move_speed": 0.2
			},
			"primary_attributes": ["magic_power", "mp", "move_speed"],
			"secondary_attributes": ["attack_speed"],
			"skills": ["fireball", "ice_spike", "lightning_storm"],
			"tier": 1
		}),
		"priest": ClassData.from_dict({
			"id": "priest",
			"name": "牧师",
			"description": "治疗/辅助，法强/蓝量/移速翻倍",
			"stat_multipliers": {
				"magic_power": 2.0,
				"mp": 2.0,
				"move_speed": 2.0
			},
			"attribute_bonus": {
				"hp": 10,
				"mp": 20,
				"magic_power": 4,
				"move_speed": 0.2
			},
			"primary_attributes": ["magic_power", "mp", "move_speed"],
			"secondary_attributes": ["lifesteal"],
			"skills": ["heal", "purify", "resurrection"],
			"tier": 1
		}),
		"fighter": ClassData.from_dict({
			"id": "fighter",
			"name": "格斗家",
			"description": "近战控场/元素双修，均衡属性",
			"stat_multipliers": {},
			"attribute_bonus": {
				"hp": 15,
				"mp": 10,
				"attack": 3,
				"armor": 2,
				"magic_resist": 2,
				"move_speed": 0.15
			},
			"primary_attributes": ["attack", "armor", "magic_resist"],
			"secondary_attributes": ["magic_power"],
			"skills": ["ice_fist", "fire_kick", "combo"],
			"tier": 1
		})
	}

func get_class(class_id: String) -> ClassData:
	return classes.get(class_id, null)

func select_class(class_id: String):
	if class_id in classes:
		current_class = class_id
		return true
	return false

func get_current_class() -> ClassData:
	return get_class(current_class)

func can_advance(turn_level: int) -> bool:
	var requirements: Dictionary = {
		1: 10,
		2: 50,
		3: 100,
		4: 200,
		5: 300,
		6: 500,
		7: 800,
		8: 1200,
		9: 2000
	}
	return current_turn < turn_level

func advance_turn(turn_level: int, character_level: int) -> bool:
	var requirements: Dictionary = {
		1: 10,
		2: 50,
		3: 100,
		4: 200,
		5: 300,
		6: 500,
		7: 800,
		8: 1200,
		9: 2000
	}
	
	if character_level >= requirements.get(turn_level, 0):
		current_turn = turn_level
		return true
	return false

func set_quality_rank(rank: String):
	quality_rank = rank

func get_quality_rank() -> String:
	return quality_rank
