extends Node

var quest_id: String = ""
var name: String = ""
var description: String = ""
var quest_type: String = ""
var target: String = ""
var count: int = 1
var rewards: Dictionary = {}
var level_requirement: int = 1
var is_repeatable: bool = false
var prerequisites: Array = []

func _ready():
    pass

func _init(p_data: Dictionary):
    quest_id = p_data.get("id", "")
    name = p_data.get("name", "")
    description = p_data.get("description", "")
    quest_type = p_data.get("type", "")
    target = p_data.get("target", "")
    count = p_data.get("count", 1)
    rewards = p_data.get("rewards", {})
    level_requirement = p_data.get("level_requirement", 1)
    is_repeatable = p_data.get("repeatable", false)
    prerequisites = p_data.get("prerequisites", [])

func is_available(character_level: int, completed_quests: Array) -> bool:
    if character_level < level_requirement:
        return false
    
    for prereq in prerequisites:
        if prereq not in completed_quests:
            return false
    
    return true

func is_kill_quest() -> bool:
    return quest_type == "kill"

func is_collect_quest() -> bool:
    return quest_type == "collect"

func is_boss_quest() -> bool:
    return quest_type == "boss"

func get_reward_exp() -> int:
    return rewards.get("exp", 0)

func get_reward_gold() -> int:
    return rewards.get("gold", 0)

func get_reward_item() -> String:
    return rewards.get("item", "")
