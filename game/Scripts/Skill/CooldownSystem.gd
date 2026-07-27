extends Node

var cooldowns: Dictionary = {}

func _ready():
	pass

func start_cooldown(skill_id: String, cooldown_time: float):
	cooldowns[skill_id] = {
		"end_time": OS.get_ticks_msec() + cooldown_time * 1000,
		"total_duration": cooldown_time
	}

func get_cooldown_remaining(skill_id: String) -> float:
	if skill_id not in cooldowns:
		return 0.0
	
	var cooldown: Dictionary = cooldowns[skill_id]
	var remaining: float = (cooldown["end_time"] - OS.get_ticks_msec()) / 1000
	return max(0.0, remaining)

func is_on_cooldown(skill_id: String) -> bool:
	return get_cooldown_remaining(skill_id) > 0.0

func get_cooldown_progress(skill_id: String) -> float:
	if skill_id not in cooldowns:
		return 1.0
	
	var cooldown: Dictionary = cooldowns[skill_id]
	var remaining: float = get_cooldown_remaining(skill_id)
	return 1 - (remaining / cooldown["total_duration"])

func reduce_cooldown(skill_id: String, reduction: float):
	if skill_id not in cooldowns:
		return
	
	var cooldown: Dictionary = cooldowns[skill_id]
	var current_remaining: float = (cooldown["end_time"] - OS.get_ticks_msec()) / 1000
	var new_remaining: float = max(0.0, current_remaining - reduction)
	cooldown["end_time"] = OS.get_ticks_msec() + new_remaining * 1000

func reset_cooldown(skill_id: String):
	if skill_id in cooldowns:
		cooldowns.erase(skill_id)

func reset_all_cooldowns():
	cooldowns.clear()

func get_all_cooldowns() -> Dictionary:
	return cooldowns.duplicate()
