extends Node

var global_multipliers: Dictionary = {}

func _ready():
	pass

func calculate_damage(damage_data: DamageData) -> float:
	var final_damage: float = damage_data.damage
	var target_stats: CharacterStats = damage_data.target.get_node("CharacterStats") if damage_data.target.has_node("CharacterStats") else null
	
	if not target_stats:
		return final_damage
	
	match damage_data.damage_type:
		DamageData.DamageType.PHYSICAL:
			final_damage = calculate_physical_damage(final_damage, damage_data, target_stats)
		DamageData.DamageType.MAGICAL:
			final_damage = calculate_magical_damage(final_damage, damage_data, target_stats)
		DamageData.DamageType.TRUE:
			pass
		DamageData.DamageType.PERCENTAGE_HP:
			final_damage = calculate_percentage_damage(final_damage, damage_data, target_stats)
		DamageData.DamageType.SOUL:
			pass
		DamageData.DamageType.UNDEAD:
			pass
	
	if damage_data.is_crit:
		final_damage *= damage_data.crit_multiplier
	
	return max(1.0, final_damage)

func calculate_physical_damage(damage: float, damage_data: DamageData, target_stats: CharacterStats) -> float:
	var armor: float = target_stats.get_stat("armor")
	var armor_penetration: float = damage_data.armor_penetration
	
	var effective_armor: float = armor * (1 - armor_penetration)
	var reduction: float = effective_armor / (effective_armor + 100)
	
	return damage * (1 - reduction)

func calculate_magical_damage(damage: float, damage_data: DamageData, target_stats: CharacterStats) -> float:
	var magic_resist: float = target_stats.get_stat("magic_resist")
	var magic_penetration: float = damage_data.magic_penetration
	
	var effective_magic_resist: float = magic_resist * (1 - magic_penetration)
	var reduction: float = effective_magic_resist / (effective_magic_resist + 100)
	
	return damage * (1 - reduction)

func calculate_percentage_damage(damage: float, damage_data: DamageData, target_stats: CharacterStats) -> float:
	return target_stats.get_stat("hp") * damage / 100.0

func apply_damage(damage_data: DamageData):
	var final_damage: float = calculate_damage(damage_data)
	
	EventBus.emit_damage(damage_data.attacker, damage_data.target, final_damage, str(damage_data.damage_type))
	
	if damage_data.target.has_method("take_damage"):
		damage_data.target.take_damage(final_damage, str(damage_data.damage_type))
	
	if damage_data.lifesteal > 0:
		apply_lifesteal(damage_data.attacker, final_damage, damage_data.lifesteal)
	
	if damage_data.thorns_return > 0 and damage_data.target.has_node("CharacterStats"):
		apply_thorns(damage_data.attacker, damage_data.target, final_damage, damage_data.thorns_return)

func apply_lifesteal(attacker: Node, damage: float, lifesteal: float):
	if attacker.has_node("CharacterStats"):
		var stats: CharacterStats = attacker.get_node("CharacterStats")
		var heal_amount: float = damage * lifesteal
		var current_hp: float = stats.get_stat("hp")
		var max_hp: float = stats.get_stat("hp")
		stats.set_base_stat("hp", min(max_hp, current_hp + heal_amount))

func apply_thorns(attacker: Node, target: Node, damage: float, thorns_return: float):
	var thorns_damage: float = damage * thorns_return
	if attacker.has_method("take_damage"):
		attacker.take_damage(thorns_damage, "thorns")

func check_crit(attacker_stats: CharacterStats, target_stats: CharacterStats) -> bool:
	var crit_rate: float = attacker_stats.get_stat("crit_rate")
	var luck: float = attacker_stats.get_stat("luck")
	var crit_chance: float = crit_rate + luck * 0.01
	
	return randf() < crit_chance

func get_crit_multiplier(attacker_stats: CharacterStats) -> float:
	return attacker_stats.get_stat("crit_damage")
