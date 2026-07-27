extends Node

var skills: Dictionary = {}
var cooldown_system: CooldownSystem = null
var character_stats: CharacterStats = null

func _ready():
	cooldown_system = CooldownSystem.new()
	add_child(cooldown_system)
	load_base_skills()

func set_character_stats(stats: CharacterStats):
	character_stats = stats

func load_base_skills():
	skills = {
		"normal_shot": SkillData.from_dict({
			"id": "normal_shot",
			"name": "普通射击",
			"description": "弓箭手基础攻击，射出一支箭",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 0.0,
			"cooldown": 0.0,
			"range": 200.0,
			"damage": 100.0,
			"damage_scaling": {"attack": 1.0},
			"target_type": "single",
			"cast_type": "instant",
			"required_level": 1
		}),
		"five_arrows": SkillData.from_dict({
			"id": "five_arrows",
			"name": "五连箭",
			"description": "快速射出五支箭，每支箭造成攻击力50%的伤害",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 20.0,
			"cooldown": 8.0,
			"range": 200.0,
			"damage": 50.0,
			"damage_scaling": {"attack": 0.5},
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.DAMAGE, "value": 50, "stack_count": 5})],
			"target_type": "single",
			"cast_type": "instant",
			"required_level": 5
		}),
		"thunder_jump": SkillData.from_dict({
			"id": "thunder_jump",
			"name": "雷神跳",
			"description": "向指定方向跳跃，落地时对周围敌人造成伤害",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.MAGICAL,
			"mana_cost": 30.0,
			"cooldown": 15.0,
			"range": 150.0,
			"damage": 200.0,
			"damage_scaling": {"magic_power": 1.5},
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.DAMAGE, "value": 200, "target_type": "area"})],
			"target_type": "area",
			"cast_type": "instant",
			"required_level": 10
		}),
		"double_shield": SkillData.from_dict({
			"id": "double_shield",
			"name": "双重护盾",
			"description": "获得最大生命值20%的护盾，持续5秒",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 25.0,
			"cooldown": 12.0,
			"range": 0.0,
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.SHIELD, "value": 0.2, "duration": 5.0})],
			"target_type": "self",
			"cast_type": "instant",
			"required_level": 5
		}),
		"double_armor": SkillData.from_dict({
			"id": "double_armor",
			"name": "双重护甲",
			"description": "护甲和魔法抗性翻倍，持续3秒",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 35.0,
			"cooldown": 20.0,
			"range": 0.0,
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.BUFF, "value": 1.0, "duration": 3.0, "stat_name": "armor"}), SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.BUFF, "value": 1.0, "duration": 3.0, "stat_name": "magic_resist"})],
			"target_type": "self",
			"cast_type": "instant",
			"required_level": 10
		}),
		"double_slash": SkillData.from_dict({
			"id": "double_slash",
			"name": "双重斩击",
			"description": "挥舞武器造成范围伤害",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 20.0,
			"cooldown": 8.0,
			"range": 100.0,
			"damage": 150.0,
			"damage_scaling": {"attack": 1.2},
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.DAMAGE, "value": 150, "target_type": "area"})],
			"target_type": "area",
			"cast_type": "instant",
			"required_level": 5
		}),
		"stealth": SkillData.from_dict({
			"id": "stealth",
			"name": "隐身",
			"description": "进入隐身状态，移动速度提升50%，攻击时显形",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 20.0,
			"cooldown": 15.0,
			"range": 0.0,
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.BUFF, "value": 0.5, "duration": 10.0, "stat_name": "move_speed"})],
			"target_type": "self",
			"cast_type": "instant",
			"required_level": 5
		}),
		"backstab": SkillData.from_dict({
			"id": "backstab",
			"name": "背刺",
			"description": "从背后攻击造成300%伤害",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 30.0,
			"cooldown": 12.0,
			"range": 50.0,
			"damage": 300.0,
			"damage_scaling": {"attack": 3.0},
			"target_type": "single",
			"cast_type": "instant",
			"required_level": 10
		}),
		"shadow_step": SkillData.from_dict({
			"id": "shadow_step",
			"name": "暗影步",
			"description": "瞬间传送到目标背后",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.PHYSICAL,
			"mana_cost": 25.0,
			"cooldown": 18.0,
			"range": 150.0,
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.TELEPORT})],
			"target_type": "single",
			"cast_type": "instant",
			"required_level": 15
		}),
		"fireball": SkillData.from_dict({
			"id": "fireball",
			"name": "火球术",
			"description": "发射一颗火球造成伤害",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.MAGICAL,
			"mana_cost": 15.0,
			"cooldown": 5.0,
			"range": 200.0,
			"damage": 80.0,
			"damage_scaling": {"magic_power": 0.8},
			"target_type": "single",
			"cast_type": "instant",
			"required_level": 1
		}),
		"heal": SkillData.from_dict({
			"id": "heal",
			"name": "治愈术",
			"description": "恢复目标生命值",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.MAGICAL,
			"mana_cost": 20.0,
			"cooldown": 8.0,
			"range": 150.0,
			"effects": [SkillEffect.from_dict({"effect_type": SkillEffect.EffectType.HEAL, "value": 100})],
			"target_type": "ally",
			"cast_type": "instant",
			"required_level": 1
		}),
		"purify": SkillData.from_dict({
			"id": "purify",
			"name": "净化",
			"description": "清除目标所有负面效果",
			"skill_type": SkillData.SkillType.ACTIVE,
			"damage_type": SkillData.DamageType.MAGICAL,
			"mana_cost": 30.0,
			"cooldown": 15.0,
			"range": 150.0,
			"target_type": "ally",
			"cast_type": "instant",
			"required_level": 10
		})
	}

func cast_skill(skill_id: String, target: Node = null):
	if skill_id not in skills:
		return false
	
	var skill: SkillData = skills[skill_id]
	
	if not can_cast(skill):
		return false
	
	if character_stats and character_stats.get_stat("mp") < skill.mana_cost:
		return false
	
	cooldown_system.start_cooldown(skill_id, skill.cooldown)
	
	if character_stats:
		character_stats.add_to_base_stat("mp", -skill.mana_cost)
	
	apply_skill_effects(skill, target)
	
	EventBus.emit_skill_cast(get_parent(), skill_id, target)
	return true

func can_cast(skill: SkillData) -> bool:
	if cooldown_system.is_on_cooldown(skill.id):
		return false
	
	if character_stats and character_stats.get_stat("mp") < skill.mana_cost:
		return false
	
	return true

func apply_skill_effects(skill: SkillData, target: Node):
	var base_damage: float = skill.damage
	
	if character_stats:
		for stat_name in skill.damage_scaling:
			var scaling: float = skill.damage_scaling[stat_name]
			var stat_value: float = character_stats.get_stat(stat_name)
			base_damage += stat_value * scaling
	
	var damage_data: DamageData = DamageData.create(get_parent(), target, base_damage, skill.damage_type)
	
	for effect in skill.effects:
		if randf() < effect.chance:
			apply_effect(effect, target, damage_data)
	
	if skill.damage > 0 and target:
		DamageSystem.apply_damage(damage_data)

func apply_effect(effect: SkillEffect, target: Node, damage_data: DamageData):
	if effect.effect_type == SkillEffect.EffectType.HEAL:
		if target.has_node("CharacterStats"):
			var stats: CharacterStats = target.get_node("CharacterStats")
			var heal_amount: float = effect.value
			var current_hp: float = stats.get_stat("hp")
			var max_hp: float = stats.get_stat("hp")
			stats.set_base_stat("hp", min(max_hp, current_hp + heal_amount))
	elif effect.effect_type == SkillEffect.EffectType.BUFF:
		if target.has_node("CharacterStats"):
			var stats: CharacterStats = target.get_node("CharacterStats")
			var modifier: StatModifier = StatModifier.new(effect.stat_name, effect.value, StatModifier.ModifierType.MULTIPLICATIVE, "skill", effect.duration)
			stats.add_modifier(modifier)
	elif effect.effect_type == SkillEffect.EffectType.SHIELD:
		if target.has_node("CharacterStats"):
			var stats: CharacterStats = target.get_node("CharacterStats")
			var shield_amount: float = stats.get_stat("hp") * effect.value
			var modifier: StatModifier = StatModifier.new("shield", shield_amount, StatModifier.ModifierType.ADDITIVE, "skill", effect.duration)
			stats.add_modifier(modifier)
	elif effect.effect_type == SkillEffect.EffectType.CROWD_CONTROL:
		var cc_system: CCSystem = get_node_or_null("/root/CCSystem")
		if cc_system:
			var cc_effect: CCEffect = CCEffect.new(effect.metadata.get("cc_type", CCEffect.CCType.STUN), effect.duration)
			cc_system.apply_cc(target, cc_effect)

func get_skill(skill_id: String) -> SkillData:
	return skills.get(skill_id, null)

func get_skill_cooldown(skill_id: String) -> float:
	return cooldown_system.get_cooldown_remaining(skill_id)

func is_skill_on_cooldown(skill_id: String) -> bool:
	return cooldown_system.is_on_cooldown(skill_id)
