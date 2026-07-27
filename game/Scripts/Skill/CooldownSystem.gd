extends Node

var cooldowns: Dictionary = {}

func _ready():
    cooldowns = {}

func add_cooldown(skill_id: String, cooldown_time: float):
    cooldowns[skill_id] = cooldown_time

func is_on_cooldown(skill_id: String) -> bool:
    return cooldowns.get(skill_id, 0) > 0

func get_cooldown_remaining(skill_id: String) -> float:
    return cooldowns.get(skill_id, 0)

func get_cooldown_percentage(skill_id: String, max_cooldown: float) -> float:
    var remaining = get_cooldown_remaining(skill_id)
    if max_cooldown <= 0:
        return 0.0
    return (remaining / max_cooldown) * 100.0

func update(delta: float):
    var to_remove: Array = []
    for skill_id in cooldowns:
        cooldowns[skill_id] -= delta
        if cooldowns[skill_id] <= 0:
            to_remove.append(skill_id)
    
    for skill_id in to_remove:
        cooldowns.erase(skill_id)

func reset_cooldown(skill_id: String):
    if skill_id in cooldowns:
        cooldowns[skill_id] = 0

func reset_all_cooldowns():
    cooldowns.clear()

func has_cooldown(skill_id: String) -> bool:
    return skill_id in cooldowns
