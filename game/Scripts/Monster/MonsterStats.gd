extends Node

var base_stats: Dictionary = {}
var current_stats: Dictionary = {}
var level: int = 1

func _ready():
	pass

func initialize_with_monster_data(monster_data: MonsterData):
	level = monster_data.level
	base_stats = monster_data.base_stats.duplicate()
	
	for stat_name in base_stats:
		var base_value: float = base_stats[stat_name]
		var level_multiplier: float = 1 + (level - 1) * 0.15
		base_stats[stat_name] = int(base_value * level_multiplier)
	
	current_stats = base_stats.duplicate()

func get_stat(stat_name: String) -> float:
	return current_stats.get(stat_name, 0.0)

func set_stat(stat_name: String, value: float):
	if stat_name in current_stats:
		current_stats[stat_name] = value

func add_stat(stat_name: String, value: float):
	if stat_name in current_stats:
		current_stats[stat_name] += value
