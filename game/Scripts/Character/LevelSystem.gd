extends Node

var current_level: int = 1
var current_experience: int = 0
var total_experience: int = 0
var free_attribute_points: int = 0

func _ready():
	pass

func calculate_required_experience(level: int) -> int:
	return level * 100 + level * level * 10

func get_experience_progress() -> float:
	var required: int = calculate_required_experience(current_level)
	return float(current_experience) / float(required)

func add_experience(amount: int, source_level: int = 0):
	var adjusted_amount: int = amount
	var level_diff: int = source_level - current_level
	
	if level_diff > 0:
		adjusted_amount = int(amount * (1 + level_diff * 0.05))
	elif level_diff < -10:
		adjusted_amount = int(amount * 0.1)
	
	current_experience += adjusted_amount
	total_experience += adjusted_amount
	
	while current_experience >= calculate_required_experience(current_level):
		current_experience -= calculate_required_experience(current_level)
		current_level += 1
		free_attribute_points += 5
		EventBus.emit_level_up(self, current_level)

func spend_attribute_point(stat_name: String):
	if free_attribute_points > 0:
		free_attribute_points -= 1
		return true
	return false

func get_level_bonus(stat_name: String) -> float:
	var bonuses: Dictionary = {
		"hp": 10.0,
		"mp": 5.0,
		"attack": 2.0,
		"magic_power": 1.0,
		"armor": 1.0,
		"magic_resist": 0.5,
		"attack_speed": 0.01,
		"move_speed": 0.1
	}
	return bonuses.get(stat_name, 0.0) * (current_level - 1)

func get_character_level() -> int:
	return current_level

func get_free_attribute_points() -> int:
	return free_attribute_points
