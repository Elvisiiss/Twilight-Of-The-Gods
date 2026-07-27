extends Node

var talents: Dictionary = {}
var active_talents: Array = []
var talent_slots: int = 1

func _ready():
	load_base_talents()

func load_base_talents():
	talents = {
		"divine_punishment_hand": TalentData.from_dict({
			"id": "divine_punishment_hand",
			"name": "天罚之手",
			"description": "每次普攻造成目标最大HP百分比的真实伤害，每次普攻永久提升自身生命值",
			"grade": TalentData.TalentGrade.SUPER_DIVINE,
			"effect_type": "true_damage_percentage",
			"effect_value": 0.03,
			"effect_target": "enemy",
			"max_stars": 10,
			"current_stars": 1,
			"is_active": false,
			"skill_effects": ["true_damage", "hp_steal_permanent"]
		}),
		"divine_punishment_brain": TalentData.from_dict({
			"id": "divine_punishment_brain",
			"name": "天罚之脑",
			"description": "无视护盾、减伤、反伤等负面效果，造成绝对真实伤害",
			"grade": TalentData.TalentGrade.SUPER_DIVINE,
			"effect_type": "penetrate_defense",
			"effect_value": 1.0,
			"effect_target": "self",
			"max_stars": 10,
			"current_stars": 1,
			"is_active": false,
			"skill_effects": ["ignore_shield", "ignore_reduction", "ignore_thorns"]
		}),
		"divine_punishment_heart": TalentData.from_dict({
			"id": "divine_punishment_heart",
			"name": "天罚之心",
			"description": "生死簿每造成一次伤害叠加4点生命值",
			"grade": TalentData.TalentGrade.SUPER_DIVINE,
			"effect_type": "hp_stack",
			"effect_value": 4.0,
			"effect_target": "self",
			"max_stars": 10,
			"current_stars": 1,
			"is_active": false,
			"skill_effects": ["hp_regeneration"]
		}),
		"five_star_attributes": TalentData.from_dict({
			"id": "five_star_attributes",
			"name": "德智体美劳",
			"description": "自由属性点×5，加点提升全属性",
			"grade": TalentData.TalentGrade.SAINT,
			"effect_type": "attribute_multiplier",
			"effect_value": 5.0,
			"effect_target": "self",
			"is_active": true,
			"skill_effects": ["all_attributes"]
		}),
		"ten_times_damage_reduction": TalentData.from_dict({
			"id": "ten_times_damage_reduction",
			"name": "十倍减伤",
			"description": "承受伤害降低为十分之一",
			"grade": TalentData.TalentGrade.SAINT,
			"effect_type": "damage_reduction",
			"effect_value": 0.9,
			"effect_target": "self",
			"is_active": true,
			"skill_effects": ["damage_reduction"]
		}),
		"ten_times_true_damage": TalentData.from_dict({
			"id": "ten_times_true_damage",
			"name": "十倍真伤",
			"description": "攻击造成10倍真实伤害",
			"grade": TalentData.TalentGrade.SAINT,
			"effect_type": "true_damage_multiplier",
			"effect_value": 10.0,
			"effect_target": "enemy",
			"is_active": true,
			"skill_effects": ["true_damage"]
		}),
		"life_blessing": TalentData.from_dict({
			"id": "life_blessing",
			"name": "生命赐福",
			"description": "给予盟友生命增益",
			"grade": TalentData.TalentGrade.SAINT,
			"effect_type": "heal_ally",
			"effect_value": 1000.0,
			"effect_target": "ally",
			"is_active": false,
			"skill_effects": ["heal"]
		}),
		"eternal_body": TalentData.from_dict({
			"id": "eternal_body",
			"name": "万法之躯",
			"description": "所有本源法则抗性与悟性每秒+1",
			"grade": TalentData.TalentGrade.ETERNAL,
			"effect_type": "law_resistance",
			"effect_value": 1.0,
			"effect_target": "self",
			"is_active": true,
			"skill_effects": ["resistance_up", "comprehension_up"]
		}),
		"devour_all": TalentData.from_dict({
			"id": "devour_all",
			"name": "吞天噬地",
			"description": "吞噬方圆100米内一切获取属性",
			"grade": TalentData.TalentGrade.HEAVENLY_DAO,
			"effect_type": "devour",
			"effect_value": 100.0,
			"effect_target": "area",
			"is_active": false,
			"skill_effects": ["attribute_steal"]
		}),
		"death_reincarnation": TalentData.from_dict({
			"id": "death_reincarnation",
			"name": "死亡轮回",
			"description": "普攻有概率秒杀任何单位",
			"grade": TalentData.TalentGrade.DIVINE,
			"effect_type": "instant_kill",
			"effect_value": 0.005,
			"effect_target": "enemy",
			"max_stars": 10,
			"current_stars": 1,
			"is_active": false,
			"skill_effects": ["instant_kill"]
		})
	}

func get_talent(talent_id: String) -> TalentData:
	return talents.get(talent_id, null)

func equip_talent(talent_id: String) -> bool:
	if talent_id not in talents:
		return false
	if len(active_talents) >= talent_slots:
		return false
	
	active_talents.append(talent_id)
	talents[talent_id].is_active = true
	return true

func unequip_talent(talent_id: String):
	if talent_id in active_talents:
		active_talents.erase(talent_id)
		talents[talent_id].is_active = false

func add_proficiency(talent_id: String, amount: int):
	if talent_id in talents:
		talents[talent_id].proficiency += amount
		check_star_upgrade(talent_id)

func check_star_upgrade(talent_id: String):
	var talent: TalentData = talents.get(talent_id, null)
	if not talent:
		return
	
	var thresholds: Array = [100, 500, 1000, 5000, 10000, 50000, 100000, 500000, 1000000, 10000000]
	for i in range(len(thresholds)):
		if talent.proficiency >= thresholds[i] and talent.current_stars < i + 1:
			talent.current_stars = i + 1
			update_talent_effect(talent)

func update_talent_effect(talent: TalentData):
	match talent.effect_type:
		"true_damage_percentage":
			talent.effect_value = 0.01 + talent.current_stars * 0.01
		"instant_kill":
			talent.effect_value = 0.005 + talent.current_stars * 0.005
		"hp_stack":
			talent.effect_value = 1.0 + talent.current_stars * 0.5

func unlock_slot():
	talent_slots += 1

func get_active_talents() -> Array:
	var result: Array = []
	for talent_id in active_talents:
		result.append(talents[talent_id])
	return result

func get_active_talent_ids() -> Array:
	return active_talents
