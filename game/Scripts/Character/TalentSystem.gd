extends Node

enum TalentRarity { YELLOW, MYSTIC, EARTH, HEAVEN, SAINT, DIVINE, SUPER_DIVINE, ETERNAL, HEAVENLY_DAO }

var talents: Dictionary = {}
var active_talents: Dictionary = {}

func _ready():
    talents = {}
    active_talents = {}
    load_talents()

func load_talents():
    talents = {
        "heavenly_punishment_hand": {
            "id": "heavenly_punishment_hand",
            "name": "天罚之手",
            "rarity": "super_divine",
            "description": "每次普攻造成自身HP百分比的真实伤害，每次普攻永久提升HP",
            "star_effects": {
                2: {"true_damage_percent": 0.03, "hp_per_hit": 3},
                3: {"true_damage_percent": 0.04, "hp_per_hit": 5},
                4: {"true_damage_percent": 0.05, "hp_per_hit": 10},
                5: {"true_damage_percent": 0.07, "hp_per_hit": 20},
                6: {"true_damage_percent": 0.1, "hp_per_hit": 50},
                7: {"true_damage_percent": 0.15, "hp_per_hit": 100}
            },
            "max_star": 10,
            "current_star": 2
        },
        "heavenly_punishment_heart": {
            "id": "heavenly_punishment_heart",
            "name": "天罚之心",
            "rarity": "super_divine",
            "description": "生死簿每造成一次伤害叠加4点生命值",
            "star_effects": {
                4: {"hp_per_damage": 4, "daily_hp": 345600},
                5: {"hp_per_damage": 8, "daily_hp": 691200},
                6: {"hp_per_damage": 16, "daily_hp": 1382400},
                7: {"hp_per_damage": 32, "daily_hp": 2764800},
                8: {"hp_per_damage": 64, "daily_hp": 5529600}
            },
            "max_star": 10,
            "current_star": 0
        },
        "heavenly_punishment_brain": {
            "id": "heavenly_punishment_brain",
            "name": "天罚之脑",
            "rarity": "super_divine",
            "description": "无视护盾减伤、反伤负面，造成绝对真实伤害",
            "star_effects": {
                5: {"max_hp_reduction": 10000},
                6: {"max_hp_reduction": 100000},
                7: {"max_hp_reduction": 1000000},
                8: {"max_hp_reduction": 10000000},
                9: {"max_hp_reduction": 100000000},
                10: {"max_hp_reduction": 1000000000}
            },
            "max_star": 10,
            "current_star": 0
        },
        "all_round_development": {
            "id": "all_round_development",
            "name": "德智体美",
            "rarity": "saint",
            "description": "自由属性点×5，加点提升全属性",
            "effect": {"free_attribute_multiplier": 5, "all_attribute_boost": true},
            "max_star": 1,
            "current_star": 0
        },
        "life_blessing": {
            "id": "life_blessing",
            "name": "生命馈赠",
            "rarity": "saint",
            "description": "给予盟友生命/辅助型生命增益",
            "effect": {"ally_hp_boost": 0.2},
            "max_star": 1,
            "current_star": 0
        },
        "infinite_blade_range": {
            "id": "infinite_blade_range",
            "name": "无穷剑距",
            "rarity": "divine",
            "description": "每击杀野怪永久+1攻击力，每击杀boss永久+0.01攻击距离",
            "effect": {"attack_per_kill": 1, "range_per_boss_kill": 0.01},
            "max_star": 1,
            "current_star": 0
        },
        "absolute_slow": {
            "id": "absolute_slow",
            "name": "绝对迟缓",
            "rarity": "saint",
            "description": "普攻降低敌方移速5%，不可被净化",
            "effect": {"move_speed_reduction": 0.05},
            "max_star": 1,
            "current_star": 0
        },
        "pet_evolution": {
            "id": "pet_evolution",
            "name": "御兽进化",
            "rarity": "saint",
            "description": "进化召唤物品质和战力",
            "effect": {"pet_evolution_bonus": 0.5},
            "max_star": 1,
            "current_star": 0
        }
    }

func activate_talent(talent_id: String):
    if not talent_id in talents:
        return false
    
    active_talents[talent_id] = talents[talent_id].duplicate()
    return true

func deactivate_talent(talent_id: String):
    if talent_id in active_talents:
        active_talents.erase(talent_id)
        return true
    return false

func is_talent_active(talent_id: String) -> bool:
    return talent_id in active_talents

func get_talent_data(talent_id: String) -> Dictionary:
    return talents.get(talent_id, {})

func get_active_talent_data(talent_id: String) -> Dictionary:
    return active_talents.get(talent_id, {})

func get_all_talents() -> Array:
    return talents.values()

func get_active_talents() -> Array:
    return active_talents.values()

func get_talent_rarity(talent_id: String) -> String:
    var talent = talents.get(talent_id, {})
    return talent.get("rarity", "")

func upgrade_talent(talent_id: String) -> bool:
    if not talent_id in active_talents:
        return false
    
    var talent = active_talents[talent_id]
    var current_star = talent.get("current_star", 0)
    var max_star = talent.get("max_star", 1)
    
    if current_star >= max_star:
        return false
    
    talent["current_star"] = current_star + 1
    return true

func get_talent_current_star(talent_id: String) -> int:
    var talent = active_talents.get(talent_id, {})
    return talent.get("current_star", 0)

func get_talent_max_star(talent_id: String) -> int:
    var talent = talents.get(talent_id, {})
    return talent.get("max_star", 1)

func apply_talent_effects(character: Node):
    for talent_id in active_talents:
        var talent = active_talents[talent_id]
        var current_star = talent.get("current_star", 0)
        var star_effects = talent.get("star_effects", {})
        var effect = talent.get("effect", {})
        
        if current_star in star_effects:
            var star_effect = star_effects[current_star]
            _apply_effect(character, star_effect)
        
        if effect:
            _apply_effect(character, effect)

func _apply_effect(character: Node, effect: Dictionary):
    for stat_name in effect:
        var value = effect[stat_name]
        
        if character.has_method("add_modifier"):
            var modifier = StatModifier.new(stat_name, value, StatModifier.ModifierType.MULTIPLICATIVE, "talent", 0, true)
            character.add_modifier(modifier)

func equip_talent(talent_id: String, star: int = 1):
    if not talent_id in talents:
        return false
    
    active_talents[talent_id] = talents[talent_id].duplicate()
    active_talents[talent_id]["current_star"] = star
    return true

func get_talent(talent_id: String) -> Dictionary:
    return active_talents.get(talent_id, talents.get(talent_id, {}))

func get_equipped_talents() -> Array:
    return active_talents.keys()
