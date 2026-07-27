extends Node

var skills: Dictionary = {}

func _ready():
    load_skills()

func load_skills():
    skills = {
        "warrior_slash": {
            "id": "warrior_slash",
            "name": "猛击",
            "description": "战士基础技能，快速挥砍敌人",
            "damage": 1.5,
            "damage_type": "physical",
            "mp_cost": 10,
            "cooldown": 1.0,
            "range": 100,
            "count": 1
        },
        "warrior_shield_bash": {
            "id": "warrior_shield_bash",
            "name": "盾击",
            "description": "用盾牌猛击敌人，造成眩晕",
            "damage": 1.0,
            "damage_type": "physical",
            "mp_cost": 20,
            "cooldown": 5.0,
            "range": 80,
            "effects": {"stun": 2.0}
        },
        "warrior_rage": {
            "id": "warrior_rage",
            "name": "狂暴",
            "description": "进入狂暴状态，大幅提升攻击力",
            "damage_type": "buff",
            "mp_cost": 30,
            "cooldown": 30.0,
            "duration": 10.0,
            "effects": {"attack": 0.5, "attack_speed": 0.3}
        },
        "warrior_charge": {
            "id": "warrior_charge",
            "name": "冲锋",
            "description": "向前冲锋，撞击敌人",
            "damage": 2.0,
            "damage_type": "physical",
            "mp_cost": 25,
            "cooldown": 10.0,
            "range": 300,
            "distance": 300,
            "effects": {"stun": 1.0}
        },
        "mage_fireball": {
            "id": "mage_fireball",
            "name": "火球术",
            "description": "发射一颗火球攻击敌人",
            "damage": 2.0,
            "damage_type": "magical",
            "mp_cost": 15,
            "cooldown": 2.0,
            "range": 500,
            "count": 1
        },
        "mage_frost_nova": {
            "id": "mage_frost_nova",
            "name": "冰霜新星",
            "description": "释放冰霜能量，冻结周围敌人",
            "damage": 1.5,
            "damage_type": "magical",
            "mp_cost": 30,
            "cooldown": 8.0,
            "range": 200,
            "count": 5,
            "effects": {"slow": 0.5}
        },
        "mage_invisibility": {
            "id": "mage_invisibility",
            "name": "隐身术",
            "description": "使自己隐身，脱离战斗",
            "damage_type": "buff",
            "mp_cost": 50,
            "cooldown": 60.0,
            "duration": 15.0,
            "effects": {"invisible": true}
        },
        "mage_meteor": {
            "id": "mage_meteor",
            "name": "陨石术",
            "description": "召唤陨石从天而降，造成大量伤害",
            "damage": 5.0,
            "damage_type": "magical",
            "mp_cost": 80,
            "cooldown": 30.0,
            "range": 400,
            "count": 1
        },
        "archer_arrow_shot": {
            "id": "archer_arrow_shot",
            "name": "射击",
            "description": "发射箭矢攻击远方敌人",
            "damage": 1.8,
            "damage_type": "physical",
            "mp_cost": 8,
            "cooldown": 0.8,
            "range": 600,
            "count": 1
        },
        "archer_multishot": {
            "id": "archer_multishot",
            "name": "多重射击",
            "description": "同时发射多支箭矢",
            "damage": 1.2,
            "damage_type": "physical",
            "mp_cost": 25,
            "cooldown": 5.0,
            "range": 500,
            "count": 3
        },
        "archer_stealth": {
            "id": "archer_stealth",
            "name": "潜行",
            "description": "进入潜行状态，移动速度提升",
            "damage_type": "buff",
            "mp_cost": 20,
            "cooldown": 30.0,
            "duration": 10.0,
            "effects": {"move_speed": 0.3, "invisible": true}
        },
        "archer_volley": {
            "id": "archer_volley",
            "name": "箭雨",
            "description": "召唤箭雨覆盖区域",
            "damage": 2.5,
            "damage_type": "physical",
            "mp_cost": 50,
            "cooldown": 15.0,
            "range": 400,
            "count": 10
        },
        "assassin_backstab": {
            "id": "assassin_backstab",
            "name": "背刺",
            "description": "从背后攻击敌人，造成暴击伤害",
            "damage": 3.0,
            "damage_type": "physical",
            "mp_cost": 15,
            "cooldown": 3.0,
            "range": 100,
            "count": 1,
            "effects": {"crit_rate": 1.0}
        },
        "assassin_blink": {
            "id": "assassin_blink",
            "name": "闪烁",
            "description": "瞬间移动到目标位置",
            "damage_type": "movement",
            "mp_cost": 20,
            "cooldown": 8.0,
            "distance": 200
        },
        "assassin_poison": {
            "id": "assassin_poison",
            "name": "涂毒",
            "description": "使武器附着毒药，持续伤害",
            "damage_type": "buff",
            "mp_cost": 30,
            "cooldown": 15.0,
            "duration": 20.0,
            "effects": {"poison_damage": 0.1}
        },
        "assassin_execute": {
            "id": "assassin_execute",
            "name": "处决",
            "description": "对低血量敌人造成致命一击",
            "damage": 5.0,
            "damage_type": "true",
            "mp_cost": 40,
            "cooldown": 20.0,
            "range": 100,
            "count": 1
        },
        "priest_heal": {
            "id": "priest_heal",
            "name": "治愈术",
            "description": "恢复自身或队友生命值",
            "damage_type": "heal",
            "mp_cost": 20,
            "cooldown": 3.0,
            "heal_amount": 100,
            "range": 300
        },
        "priest_shield": {
            "id": "priest_shield",
            "name": "神圣护盾",
            "description": "为自己或队友添加护盾",
            "damage_type": "buff",
            "mp_cost": 30,
            "cooldown": 8.0,
            "duration": 10.0,
            "effects": {"shield": 200}
        },
        "priest_smite": {
            "id": "priest_smite",
            "name": "神圣打击",
            "description": "用神圣之力攻击敌人",
            "damage": 1.5,
            "damage_type": "magical",
            "mp_cost": 15,
            "cooldown": 2.0,
            "range": 400,
            "count": 1
        },
        "priest_resurrection": {
            "id": "priest_resurrection",
            "name": "复活术",
            "description": "复活死亡的队友",
            "damage_type": "heal",
            "mp_cost": 100,
            "cooldown": 120.0,
            "heal_amount": 9999,
            "range": 500
        },
        "summoner_summon_wolf": {
            "id": "summoner_summon_wolf",
            "name": "召唤野狼",
            "description": "召唤一只野狼协助战斗",
            "damage_type": "buff",
            "mp_cost": 30,
            "cooldown": 30.0,
            "duration": 60.0,
            "effects": {"summon_wolf": true}
        },
        "summoner_summon_golem": {
            "id": "summoner_summon_golem",
            "name": "召唤石像鬼",
            "description": "召唤一只石像鬼协助战斗",
            "damage_type": "buff",
            "mp_cost": 60,
            "cooldown": 60.0,
            "duration": 45.0,
            "effects": {"summon_golem": true}
        },
        "summoner_buff_pet": {
            "id": "summoner_buff_pet",
            "name": "宠物强化",
            "description": "强化所有召唤物",
            "damage_type": "buff",
            "mp_cost": 40,
            "cooldown": 20.0,
            "duration": 15.0,
            "effects": {"pet_attack": 0.5, "pet_hp": 0.5}
        },
        "summoner_summon_dragon": {
            "id": "summoner_summon_dragon",
            "name": "召唤巨龙",
            "description": "召唤一只巨龙协助战斗",
            "damage_type": "buff",
            "mp_cost": 100,
            "cooldown": 180.0,
            "duration": 30.0,
            "effects": {"summon_dragon": true}
        }
    }

func get_skill(skill_id: String) -> Dictionary:
    return skills.get(skill_id, {})

func get_all_skills() -> Array:
    return skills.values()

func has_skill(skill_id: String) -> bool:
    return skill_id in skills