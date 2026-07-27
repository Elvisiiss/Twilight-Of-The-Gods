extends Node

var classes: Dictionary = {}

func _ready():
    load_classes()

func load_classes():
    classes = {
        "archer": {
            "id": "archer",
            "name": "弓箭手",
            "description": "远程物理DPS，持续输出核心",
            "stat_multipliers": {
                "attack": 2.0,
                "attack_speed": 1.0,
                "crit_rate": 2.0
            },
            "base_stats": {
                "hp": 100,
                "mp": 50,
                "attack": 9,
                "magic_power": 5,
                "armor": 3,
                "magic_resist": 1,
                "attack_speed": 0.63,
                "move_speed": 3.1
            },
            "skills": ["normal_shot", "five_arrows", "thunder_jump"],
            "icon": "res://Assets/Icons/Skills/skill_five_arrows.png"
        },
        "warrior": {
            "id": "warrior",
            "name": "战士",
            "description": "坦克/近战DPS，团队前排",
            "stat_multipliers": {
                "hp": 2.0,
                "armor": 2.0,
                "magic_resist": 2.0
            },
            "base_stats": {
                "hp": 150,
                "mp": 30,
                "attack": 8,
                "magic_power": 3,
                "armor": 5,
                "magic_resist": 3,
                "attack_speed": 0.5,
                "move_speed": 2.8
            },
            "skills": ["double_armor", "double_shield", "double_slash"],
            "icon": "res://Assets/Icons/Skills/skill_double_slash.png"
        },
        "assassin": {
            "id": "assassin",
            "name": "刺客",
            "description": "近战爆发/高机动性",
            "stat_multipliers": {
                "attack": 2.0,
                "move_speed": 2.0,
                "crit_rate": 2.0
            },
            "base_stats": {
                "hp": 80,
                "mp": 40,
                "attack": 12,
                "magic_power": 4,
                "armor": 2,
                "magic_resist": 1,
                "attack_speed": 0.7,
                "move_speed": 3.5
            },
            "skills": ["stealth", "backstab", "shadow_step"],
            "icon": "res://Assets/Icons/Skills/skill_backstab.png"
        },
        "mage": {
            "id": "mage",
            "name": "法师",
            "description": "远程魔法AoE，法术炮台",
            "stat_multipliers": {
                "mp": 2.0,
                "magic_power": 2.0,
                "move_speed": 2.0
            },
            "base_stats": {
                "hp": 70,
                "mp": 100,
                "attack": 5,
                "magic_power": 12,
                "armor": 1,
                "magic_resist": 5,
                "attack_speed": 0.4,
                "move_speed": 3.2
            },
            "skills": ["fireball", "ice_spike", "lightning_storm"],
            "icon": "res://Assets/Icons/Skills/skill_fireball.png"
        },
        "priest": {
            "id": "priest",
            "name": "牧师",
            "description": "治疗/辅助/增益",
            "stat_multipliers": {
                "mp": 2.0,
                "magic_power": 2.0,
                "move_speed": 2.0
            },
            "base_stats": {
                "hp": 90,
                "mp": 100,
                "attack": 5,
                "magic_power": 10,
                "armor": 2,
                "magic_resist": 5,
                "attack_speed": 0.4,
                "move_speed": 3.0
            },
            "skills": ["heal", "purify", "resurrect"],
            "icon": "res://Assets/Icons/Skills/skill_heal.png"
        },
        "fighter": {
            "id": "fighter",
            "name": "格斗家",
            "description": "近战控场/元素双修",
            "stat_multipliers": {},
            "base_stats": {
                "hp": 100,
                "mp": 50,
                "attack": 10,
                "magic_power": 8,
                "armor": 3,
                "magic_resist": 3,
                "attack_speed": 0.6,
                "move_speed": 3.0
            },
            "skills": ["flame_fist", "ice_kick", "combo_strike"],
            "icon": "res://Assets/Icons/Skills/skill_double_slash.png"
        }
    }

func get_class_data(class_id: String) -> Dictionary:
    return classes.get(class_id, {})

func get_all_classes() -> Array:
    return classes.values()

func get_class_skills(class_id: String) -> Array:
    var class_data = get_class_data(class_id)
    return class_data.get("skills", [])

func get_class_base_stats(class_id: String) -> Dictionary:
    var class_data = get_class_data(class_id)
    return class_data.get("base_stats", {})

func get_class_stat_multipliers(class_id: String) -> Dictionary:
    var class_data = get_class_data(class_id)
    return class_data.get("stat_multipliers", {})
