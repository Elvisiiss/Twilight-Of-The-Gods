extends Node

var base_stats: Dictionary = {}
var current_stats: Dictionary = {}
var modifiers: Array = []
var class_data: Dictionary = {}
var talent_data: Dictionary = {}
var equipment_bonus: Dictionary = {}

func _ready():
	initialize_base_stats()

func initialize_base_stats():
	base_stats = {
		"hp": 100.0,
		"mp": 50.0,
		"attack": 9.0,
		"magic_power": 5.0,
		"armor": 3.0,
		"magic_resist": 1.0,
		"attack_speed": 0.63,
		"move_speed": 3.1,
		"physical_penetration": 0.0,
		"magic_penetration": 0.0,
		"crit_rate": 0.0,
		"crit_damage": 2.0,
		"lifesteal": 0.0,
		"tenacity": 0.0,
		"luck": 0.0,
		"crowd_control_resist": 0.0,
		"thorns": 0.0,
		"true_damage": 0.0,
		"divine_resistance": 0.0,
		"law_comprehension": 0.0
	}
	current_stats = base_stats.duplicate()

func calculate_final_stats():
	current_stats = {}
	for stat_name in base_stats:
		var base_value: float = base_stats[stat_name]
		var final_value: float = base_value
		
		for modifier in modifiers:
			if modifier.stat_name == stat_name:
				match modifier.modifier_type:
					StatModifier.ModifierType.ADDITIVE:
						final_value += modifier.value
					StatModifier.ModifierType.MULTIPLICATIVE:
						final_value *= (1 + modifier.value)
					StatModifier.ModifierType.PERCENTAGE:
						final_value *= (1 + modifier.value / 100)
		
		if stat_name in equipment_bonus:
			final_value += equipment_bonus[stat_name]
		
		if class_data and stat_name in class_data.get("stat_multipliers", {}):
			final_value *= class_data["stat_multipliers"][stat_name]
		
		current_stats[stat_name] = final_value
	
	current_stats["attack_speed"] = calculate_attack_speed(current_stats["attack_speed"])
	current_stats["move_speed"] = calculate_move_speed(current_stats["move_speed"])

func calculate_attack_speed(base_as: float) -> float:
	var total_as: float = base_as
	var additive_as: float = 0.0
	var current_threshold: int = 10
	
	while additive_as < total_as - 0.63:
		var remaining: float = total_as - 0.63 - additive_as
		var available_in_threshold: float = min(remaining, current_threshold)
		additive_as += available_in_threshold * pow(0.5, floor((additive_as + 0.63) / 10))
		current_threshold += 10
	
	return max(0.1, additive_as + 0.63)

func calculate_move_speed(base_ms: float) -> float:
	if base_ms <= 10:
		return base_ms
	return 10 + (base_ms - 10) * 0.05

func add_modifier(modifier: StatModifier):
	modifiers.append(modifier)
	calculate_final_stats()
	EventBus.emit_stat_change(self, modifier.stat_name, get_stat(modifier.stat_name) - modifier.value, get_stat(modifier.stat_name))

func remove_modifier(source: String):
	modifiers = modifiers.filter(func(m): return m.source != source)
	calculate_final_stats()

func update_modifiers(delta: float):
	var to_remove: Array = []
	for modifier in modifiers:
		if not modifier.is_permanent and modifier.duration > 0:
			modifier.duration -= delta
			if modifier.duration <= 0:
				to_remove.append(modifier)
	
	for modifier in to_remove:
		remove_modifier(modifier.source)

func get_stat(stat_name: String) -> float:
	return current_stats.get(stat_name, 0.0)

func set_base_stat(stat_name: String, value: float):
	if stat_name in base_stats:
		var old_value: float = base_stats[stat_name]
		base_stats[stat_name] = value
		calculate_final_stats()
		EventBus.emit_stat_change(self, stat_name, old_value, current_stats[stat_name])

func add_to_base_stat(stat_name: String, amount: float):
	if stat_name in base_stats:
		set_base_stat(stat_name, base_stats[stat_name] + amount)

func set_class_data(data: Dictionary):
	class_data = data
	calculate_final_stats()

func set_equipment_bonus(bonus: Dictionary):
	equipment_bonus = bonus
	calculate_final_stats()
