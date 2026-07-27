extends Node

enum Rarity {
	COMMON,
	ELITE,
	IRON,
	BRONZE,
	SILVER,
	GOLD,
	PLATINUM,
	DIAMOND,
	STARLIGHT,
	GRANDMASTER,
	KING,
	EMPEROR,
	GOD
}

var rarity_data: Dictionary = {}

func _ready():
	load_rarity_data()

func load_rarity_data():
	rarity_data = {
		Rarity.COMMON: {
			"name": "普通",
			"multiplier": 1.0,
			"color": Color(0.6, 0.6, 0.6),
			"extra_stats": 0,
			"special_effect_chance": 0.0
		},
		Rarity.ELITE: {
			"name": "精英",
			"multiplier": 1.3,
			"color": Color(1.0, 1.0, 1.0),
			"extra_stats": 1,
			"special_effect_chance": 0.1
		},
		Rarity.IRON: {
			"name": "黑铁",
			"multiplier": 1.6,
			"color": Color(0.2, 0.8, 0.2),
			"extra_stats": 1,
			"special_effect_chance": 0.15
		},
		Rarity.BRONZE: {
			"name": "青铜",
			"multiplier": 2.0,
			"color": Color(0.2, 0.5, 0.8),
			"extra_stats": 2,
			"special_effect_chance": 0.2
		},
		Rarity.SILVER: {
			"name": "白银",
			"multiplier": 2.5,
			"color": Color(0.8, 0.8, 0.8),
			"extra_stats": 2,
			"special_effect_chance": 0.25
		},
		Rarity.GOLD: {
			"name": "黄金",
			"multiplier": 3.0,
			"color": Color(1.0, 0.8, 0.2),
			"extra_stats": 3,
			"special_effect_chance": 0.35
		},
		Rarity.PLATINUM: {
			"name": "铂金",
			"multiplier": 4.0,
			"color": Color(0.9, 0.9, 1.0),
			"extra_stats": 3,
			"special_effect_chance": 0.45
		},
		Rarity.DIAMOND: {
			"name": "钻石",
			"multiplier": 5.0,
			"color": Color(1.0, 0.5, 1.0),
			"extra_stats": 4,
			"special_effect_chance": 0.6
		},
		Rarity.STARLIGHT: {
			"name": "星光",
			"multiplier": 6.5,
			"color": Color(0.8, 0.5, 1.0),
			"extra_stats": 4,
			"special_effect_chance": 0.7
		},
		Rarity.GRANDMASTER: {
			"name": "宗师",
			"multiplier": 8.0,
			"color": Color(1.0, 0.2, 0.2),
			"extra_stats": 5,
			"special_effect_chance": 0.8
		},
		Rarity.KING: {
			"name": "王",
			"multiplier": 10.0,
			"color": Color(0.9, 0.1, 0.9),
			"extra_stats": 5,
			"special_effect_chance": 0.9
		},
		Rarity.EMPEROR: {
			"name": "皇",
			"multiplier": 12.0,
			"color": Color(0.9, 0.1, 0.9),
			"extra_stats": 6,
			"special_effect_chance": 0.95
		},
		Rarity.GOD: {
			"name": "神",
			"multiplier": 15.0,
			"color": Color(0.5, 0.5, 1.0),
			"extra_stats": 7,
			"special_effect_chance": 1.0
		}
	}

func get_rarity_data(rarity: Rarity) -> Dictionary:
	return rarity_data.get(rarity, rarity_data[Rarity.COMMON])

func get_rarity_by_name(name: String) -> Rarity:
	for rarity in rarity_data:
		if rarity_data[rarity]["name"] == name:
			return rarity
	return Rarity.COMMON

func get_rarity_color(rarity: Rarity) -> Color:
	return get_rarity_data(rarity)["color"]

func get_rarity_multiplier(rarity: Rarity) -> float:
	return get_rarity_data(rarity)["multiplier"]
