extends Node

var base_stats: Dictionary = {}
var current_stats: Dictionary = {}
var modifiers: Array = []
var class_data: Dictionary = {}
var talent_data: Dictionary = {}
var equipment_bonus: Dictionary = {}
var free_attribute_points: int = 0

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
		"max_hp": 100.0,
		"max_mp": 50.0
	}
	current_stats = base_stats.duplicate()
	free_attribute_points = 0

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
	
	_as = calculate_attack_speed(current_stats["attack_speed"])
	_ms = calculate_move_speed(current_stats["move_speed"])
	
	current_stats["attack_speed"] = _as
	current_stats["move_speed"] = _ms
	
	if "hp" in current_stats:
		current_stats["max_hp"] = current_stats["hp"]
	if "mp" in current_stats:
		current_stats["max_mp"] = current_stats["mp"]

func calculate_attack_speed(base_as: float) -> float:
	var base_value: float = 0.63
	var added_as: float = base_as - base_value
	
	if added_as <= 0:
		return base_value
	
	var actual_as: float = base_value
	var remaining_added: float = added_as
	var threshold: int = 10
	var multiplier: float = 1.0
	
	while remaining_added > 0:
		var available_in_range: float = min(remaining_added, float(threshold))
		actual_as += available_in_range * multiplier
		remaining_added -= available_in_range
		threshold += 10
		multiplier *= 0.5
	
	return max(0.1, actual_as)

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
	for stat_name in data.get("base_stats", {}):
		if stat_name in base_stats:
			base_stats[stat_name] = float(data["base_stats"][stat_name])
	calculate_final_stats()

func set_equipment_bonus(bonus: Dictionary):
	equipment_bonus = bonus
	calculate_final_stats()

func add_free_attribute_points(points: int):
	free_attribute_points += points

func allocate_attribute(stat_name: String, points: int):
	if free_attribute_points < points:
		return false
	if stat_name not in base_stats:
		return false
	
	free_attribute_points -= points
	
	if class_data:
		var multiplier: float = class_data.get("stat_multipliers", {}).get(stat_name, 1.0)
		if stat_name == "hp" and class_data.get("id") == "warrior":
			multiplier = 2.0
		add_to_base_stat(stat_name, float(points) * multiplier)
	else:
		add_to_base_stat(stat_name, float(points))
	
	return true

func get_free_attribute_points() -> int:
	return free_attribute_points

func take_damage(damage: float):
	if "hp" in current_stats:
		var new_hp: float = max(0, current_stats["hp"] - damage)
		set_base_stat("hp", new_hp)

func heal(amount: float):
	if "hp" in current_stats:
		var max_hp: float = current_stats.get("max_hp", 100)
		var new_hp: float = min(max_hp, current_stats["hp"] + amount)
		set_base_stat("hp", new_hp)

func consume_mp(amount: float):
	if "mp" in current_stats:
		var new_mp: float = max(0, current_stats["mp"] - amount)
		set_base_stat("mp", new_mp)

func restore_mp(amount: float):
	if "mp" in current_stats:
		var max_mp: float = current_stats.get("max_mp", 50)
		var new_mp: float = min(max_mp, current_stats["mp"] + amount)
		set_base_stat("mp", new_mp)