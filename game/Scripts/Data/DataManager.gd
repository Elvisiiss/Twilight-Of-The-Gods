extends Node

var skills: Dictionary = {}
var monsters: Dictionary = {}
var items: Dictionary = {}
var quests: Dictionary = {}
var classes: Dictionary = {}
var talents: Dictionary = {}

func init():
    load_skills()
    load_monsters()
    load_items()
    load_quests()
    load_classes()
    load_talents()

func load_skills():
    skills = {
        "normal_shot": {
            "id": "normal_shot",
            "name": "普通射击",
            "type": "active",
            "damage_type": "physical",
            "damage": 1.0,
            "mp_cost": 0,
            "cooldown": 0,
            "range": 200,
            "description": "射出一支普通箭矢"
        },
        "five_arrows": {
            "id": "five_arrows",
            "name": "五箭齐发",
            "type": "active",
            "damage_type": "physical",
            "damage": 0.8,
            "mp_cost": 20,
            "cooldown": 5.0,
            "range": 200,
            "count": 5,
            "description": "同时射出五支羽箭"
        },
        "thunder_jump": {
            "id": "thunder_jump",
            "name": "雷电跳跃",
            "type": "active",
            "damage_type": "physical",
            "damage": 1.5,
            "mp_cost": 30,
            "cooldown": 8.0,
            "range": 150,
            "splash_chance": 0.5,
            "splash_damage": 0.1,
            "description": "50%概率溅射10%伤害"
        },
        "berserk": {
            "id": "berserk",
            "name": "狂暴",
            "type": "active",
            "damage_type": "buff",
            "mp_cost": 0,
            "hp_cost_percent": 0.05,
            "cooldown": 60.0,
            "duration": 10.0,
            "effects": {
                "attack_speed": 2.0
            },
            "description": "牺牲双抗，大幅提升攻速"
        },
        "unbreakable": {
            "id": "unbreakable",
            "name": "霸体",
            "type": "active",
            "damage_type": "buff",
            "mp_cost": 50,
            "cooldown": 1800.0,
            "duration": 5.0,
            "effects": {
                "crowd_control_resist": 1.0
            },
            "description": "5秒内免疫一切控制"
        },
        "spatial_blink": {
            "id": "spatial_blink",
            "name": "空间闪烁",
            "type": "active",
            "damage_type": "movement",
            "mp_cost": 15,
            "cooldown": 10.0,
            "distance": 500,
            "description": "瞬移5米，可穿过障碍物"
        },
        "starlight_purification": {
            "id": "starlight_purification",
            "name": "星月净化",
            "type": "active",
            "damage_type": "buff",
            "mp_cost": 50,
            "cooldown": 600.0,
            "duration": 10.0,
            "effects": {
                "tenacity": 0.05
            },
            "description": "移除控制/负面buff，获得5%韧性"
        },
        "bloodthirsty_dragon_armor": {
            "id": "bloodthirsty_dragon_armor",
            "name": "嗜血龙甲",
            "type": "passive",
            "damage_type": "buff",
            "heal_percent": 0.05,
            "description": "承受伤害5%转化为治疗"
        },
        "freezing_gaze": {
            "id": "freezing_gaze",
            "name": "冰冻之眼",
            "type": "passive",
            "damage_type": "control",
            "freeze_chance": 0.05,
            "freeze_duration": 2.0,
            "bonus_damage": 1.5,
            "description": "攻击5%概率冻结对手"
        },
        "revitalize": {
            "id": "revitalize",
            "name": "枯木逢春",
            "type": "passive",
            "damage_type": "heal",
            "trigger_hp_percent": 0.1,
            "heal_percent": 0.2,
            "cooldown": 43200.0,
            "description": "HP低于10%时自动恢复"
        },
        "death_samsara": {
            "id": "death_samsara",
            "name": "死亡轮回",
            "type": "passive",
            "damage_type": "special",
            "kill_chance": 0.005,
            "description": "普攻有概率秒杀敌方单位"
        },
        "heavenly_fire_meteor": {
            "id": "heavenly_fire_meteor",
            "name": "天火流星",
            "type": "passive",
            "damage_type": "aoe",
            "trigger_chance": 0.01,
            "meteor_count": 1000,
            "radius": 100,
            "description": "1%概率触发天火流星"
        }
    }

func load_monsters():
    monsters = {
        "red_eye_rabbit": {
            "id": "red_eye_rabbit",
            "name": "红眼兔",
            "rarity": "common",
            "level": 1,
            "hp": 90,
            "attack": 5,
            "armor": 0,
            "magic_resist": 0,
            "exp_reward": 10,
            "drops": ["material_herb"],
            "drop_chance": [0.3],
            "description": "新手村最常见的怪物"
        },
        "stone_beetle": {
            "id": "stone_beetle",
            "name": "石甲虫",
            "rarity": "common",
            "level": 8,
            "hp": 1200,
            "attack": 52,
            "armor": 10,
            "magic_resist": 5,
            "exp_reward": 80,
            "drops": ["material_iron_ore"],
            "drop_chance": [0.2],
            "skills": ["rock_shield"],
            "description": "拥有坚硬外壳的甲虫"
        },
        "twisted_treeant": {
            "id": "twisted_treeant",
            "name": "扭曲树人",
            "rarity": "common",
            "level": 10,
            "hp": 1900,
            "attack": 32,
            "armor": 15,
            "magic_resist": 10,
            "exp_reward": 100,
            "drops": ["material_herb", "material_iron_ore"],
            "drop_chance": [0.25, 0.15],
            "skills": ["vine_rotation", "revive"],
            "description": "被黑暗力量扭曲的树人"
        },
        "twisted_treeant_elite": {
            "id": "twisted_treeant_elite",
            "name": "扭曲树人(精英)",
            "rarity": "elite",
            "level": 10,
            "hp": 5700,
            "attack": 49,
            "armor": 25,
            "magic_resist": 15,
            "exp_reward": 300,
            "drops": ["material_herb", "material_iron_ore", "equipment_common_armor"],
            "drop_chance": [0.4, 0.3, 0.1],
            "skills": ["vine_rotation", "revive", "vine_entangle"],
            "description": "精英级扭曲树人"
        },
        "treeant_overlord": {
            "id": "treeant_overlord",
            "name": "树人统领",
            "rarity": "boss",
            "level": 10,
            "hp": 35280,
            "attack": 412,
            "armor": 50,
            "magic_resist": 30,
            "exp_reward": 1000,
            "drops": ["equipment_iron_sword", "material_herb"],
            "drop_chance": [0.5, 1.0],
            "skills": ["summon_treeant", "revive", "vine_bind", "thorn_shield", "vine_cage"],
            "description": "树人部落的统领"
        },
        "twisted_treeant_king": {
            "id": "twisted_treeant_king",
            "name": "扭曲树人王",
            "rarity": "boss",
            "level": 10,
            "hp": 116800,
            "attack": 325,
            "armor": 80,
            "magic_resist": 40,
            "exp_reward": 3000,
            "drops": ["equipment_bronze_sword", "equipment_bronze_armor"],
            "drop_chance": [0.8, 0.6],
            "skills": ["summon_treeant", "revive", "vine_bind", "thorn_shield", "vine_cage"],
            "description": "扭曲树人的王者"
        }
    }

func load_items():
    items = {
        "material_herb": {
            "id": "material_herb",
            "name": "草药",
            "type": "material",
            "rarity": "common",
            "stackable": true,
            "max_stack": 999,
            "description": "普通的草药，可用于制药"
        },
        "material_iron_ore": {
            "id": "material_iron_ore",
            "name": "铁矿石",
            "type": "material",
            "rarity": "common",
            "stackable": true,
            "max_stack": 999,
            "description": "普通的铁矿石，可用于锻造"
        },
        "consumable_hp_potion": {
            "id": "consumable_hp_potion",
            "name": "生命药水",
            "type": "consumable",
            "rarity": "common",
            "stackable": true,
            "max_stack": 99,
            "effect": {"hp_restore": 100},
            "description": "恢复100点生命值"
        },
        "consumable_mp_potion": {
            "id": "consumable_mp_potion",
            "name": "法力药水",
            "type": "consumable",
            "rarity": "common",
            "stackable": true,
            "max_stack": 99,
            "effect": {"mp_restore": 50},
            "description": "恢复50点法力值"
        },
        "equipment_common_sword": {
            "id": "equipment_common_sword",
            "name": "普通长剑",
            "type": "equipment",
            "slot": "weapon",
            "rarity": "common",
            "level_requirement": 1,
            "stats": {"attack": 10},
            "description": "普通的铁剑"
        },
        "equipment_iron_sword": {
            "id": "equipment_iron_sword",
            "name": "铁剑",
            "type": "equipment",
            "slot": "weapon",
            "rarity": "black_iron",
            "level_requirement": 10,
            "stats": {"attack": 40},
            "description": "坚固的铁制长剑"
        },
        "equipment_bronze_sword": {
            "id": "equipment_bronze_sword",
            "name": "青铜剑",
            "type": "equipment",
            "slot": "weapon",
            "rarity": "bronze",
            "level_requirement": 10,
            "stats": {"attack": 80},
            "description": "青铜铸就的长剑"
        },
        "equipment_common_armor": {
            "id": "equipment_common_armor",
            "name": "普通护甲",
            "type": "equipment",
            "slot": "armor",
            "rarity": "common",
            "level_requirement": 1,
            "stats": {"armor": 5},
            "description": "普通的布甲"
        },
        "equipment_bronze_armor": {
            "id": "equipment_bronze_armor",
            "name": "青铜护甲",
            "type": "equipment",
            "slot": "armor",
            "rarity": "bronze",
            "level_requirement": 10,
            "stats": {"armor": 30},
            "description": "青铜打造的护甲"
        }
    }

func load_quests():
    quests = {
        "q1_kill_rabbits": {
            "id": "q1_kill_rabbits",
            "name": "消灭红眼兔",
            "description": "在新手村附近消灭10只红眼兔",
            "type": "kill",
            "target": "red_eye_rabbit",
            "count": 10,
            "rewards": {"exp": 100, "gold": 10},
            "level_requirement": 1
        },
        "q2_kill_beetles": {
            "id": "q2_kill_beetles",
            "name": "消灭石甲虫",
            "description": "消灭5只石甲虫",
            "type": "kill",
            "target": "stone_beetle",
            "count": 5,
            "rewards": {"exp": 400, "gold": 50},
            "level_requirement": 5
        },
        "q3_treeant_boss": {
            "id": "q3_treeant_boss",
            "name": "挑战树人王",
            "description": "击败扭曲树人王",
            "type": "boss",
            "target": "twisted_treeant_king",
            "count": 1,
            "rewards": {"exp": 5000, "gold": 500, "item": "equipment_bronze_sword"},
            "level_requirement": 10
        }
    }

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
            "skills": ["normal_shot", "five_arrows", "thunder_jump"]
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
            "skills": ["double_armor", "double_shield", "double_slash"]
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
            "skills": ["stealth", "backstab", "shadow_step"]
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
            "skills": ["fireball", "ice_spike", "lightning_storm"]
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
            "skills": ["heal", "purify", "resurrect"]
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
            "skills": ["flame_fist", "ice_kick", "combo_strike"]
        }
    }

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
            "max_star": 10
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
            "max_star": 10
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
            "max_star": 10
        },
        "all_round_development": {
            "id": "all_round_development",
            "name": "德智体美",
            "rarity": "saint",
            "description": "自由属性点×5，加点提升全属性",
            "effect": {"free_attribute_multiplier": 5, "all_attribute_boost": true},
            "max_star": 1
        },
        "life_blessing": {
            "id": "life_blessing",
            "name": "生命馈赠",
            "rarity": "saint",
            "description": "给予盟友生命/辅助型生命增益",
            "effect": {"ally_hp_boost": 0.2},
            "max_star": 1
        },
        "infinite_blade_range": {
            "id": "infinite_blade_range",
            "name": "无穷剑距",
            "rarity": "divine",
            "description": "每击杀野怪永久+1攻击力，每击杀boss永久+0.01攻击距离",
            "effect": {"attack_per_kill": 1, "range_per_boss_kill": 0.01},
            "max_star": 1
        },
        "absolute_slow": {
            "id": "absolute_slow",
            "name": "绝对迟缓",
            "rarity": "saint",
            "description": "普攻降低敌方移速5%，不可被净化",
            "effect": {"move_speed_reduction": 0.05},
            "max_star": 1
        },
        "pet_evolution": {
            "id": "pet_evolution",
            "name": "御兽进化",
            "rarity": "saint",
            "description": "进化召唤物品质和战力",
            "effect": {"pet_evolution_bonus": 0.5},
            "max_star": 1
        }
    }

func get_skill(skill_id: String) -> Dictionary:
    return skills.get(skill_id, {})

func get_monster(monster_id: String) -> Dictionary:
    return monsters.get(monster_id, {})

func get_item(item_id: String) -> Dictionary:
    return items.get(item_id, {})

func get_quest(quest_id: String) -> Dictionary:
    return quests.get(quest_id, {})

func get_class(class_id: String) -> Dictionary:
    return classes.get(class_id, {})

func get_talent(talent_id: String) -> Dictionary:
    return talents.get(talent_id, {})
