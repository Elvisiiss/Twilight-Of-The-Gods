extends Node

var active_quests: Dictionary = {}
var completed_quests: Array = []
var quest_progress: Dictionary = {}

func _ready():
    active_quests = {}
    completed_quests = []
    quest_progress = {}

func add_quest(quest_id: String):
    var data_manager = DataManager.new()
    data_manager.init()
    var quest_data = data_manager.get_quest(quest_id)
    
    if quest_data.empty():
        return false
    
    active_quests[quest_id] = quest_data
    quest_progress[quest_id] = 0
    
    return true

func remove_quest(quest_id: String):
    if quest_id in active_quests:
        active_quests.erase(quest_id)
        if quest_id in quest_progress:
            quest_progress.erase(quest_id)
        return true
    return false

func update_quest_progress(quest_id: String, target_type: String, amount: int = 1):
    if not quest_id in active_quests:
        return false
    
    var quest = active_quests[quest_id]
    if quest.get("type", "") != target_type:
        return false
    
    quest_progress[quest_id] += amount
    
    if is_quest_complete(quest_id):
        complete_quest(quest_id)
    
    return true

func is_quest_complete(quest_id: String) -> bool:
    if not quest_id in active_quests:
        return false
    
    var quest = active_quests[quest_id]
    var target_count = quest.get("count", 0)
    var current_progress = quest_progress.get(quest_id, 0)
    
    return current_progress >= target_count

func complete_quest(quest_id: String):
    if not quest_id in active_quests:
        return
    
    var quest = active_quests[quest_id]
    var rewards = quest.get("rewards", {})
    
    _apply_rewards(rewards)
    
    completed_quests.append(quest_id)
    remove_quest(quest_id)
    
    var game_manager = get_parent()
    if game_manager and game_manager.has_method("get_event_bus"):
        game_manager.get_event_bus().emit_quest_complete(get_parent(), quest_id)

func _apply_rewards(rewards: Dictionary):
    if "exp" in rewards:
        if get_parent().has_method("gain_experience"):
            get_parent().gain_experience(rewards["exp"])
    
    if "gold" in rewards:
        if get_parent().has_method("add_gold"):
            get_parent().add_gold(rewards["gold"])
    
    if "item" in rewards:
        var data_manager = DataManager.new()
        data_manager.init()
        var item_data = data_manager.get_item(rewards["item"])
        
        if get_parent().has_method("add_item"):
            get_parent().add_item(item_data)

func get_active_quests() -> Array:
    var result = []
    for quest_id in active_quests:
        var quest = active_quests[quest_id]
        quest["progress"] = quest_progress.get(quest_id, 0)
        result.append(quest)
    return result

func get_completed_quests() -> Array:
    return completed_quests

func get_quest_progress(quest_id: String) -> int:
    return quest_progress.get(quest_id, 0)

func has_active_quest(quest_id: String) -> bool:
    return quest_id in active_quests

func has_completed_quest(quest_id: String) -> bool:
    return quest_id in completed_quests

func get_quest_by_target(target_id: String) -> Dictionary:
    for quest_id in active_quests:
        var quest = active_quests[quest_id]
        if quest.get("target", "") == target_id:
            return quest
    return {}
