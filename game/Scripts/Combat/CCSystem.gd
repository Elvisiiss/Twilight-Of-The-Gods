extends Node

var active_cc_effects: Dictionary = {}
var anti_cc_items: Dictionary = {}

func _ready():
	load_anti_cc_items()

func load_anti_cc_items():
	anti_cc_items = {
		"purification_amulet": {
			"name": "净化玉坠",
			"resistance": 0.8,
			"max_resistance": 0.93,
			"level": 1
		}
	}

func apply_cc(target: Node, cc_effect: CCEffect):
	if not is_valid_node(target):
		return false
	
	if has_immunity(target, cc_effect):
		return false
	
	var node_path: String = str(target.get_path())
	if node_path not in active_cc_effects:
		active_cc_effects[node_path] = []
	
	var tenacity: float = get_tenacity(target)
	var final_duration: float = cc_effect.duration * (1 - tenacity)
	
	var reduced_effect: CCEffect = CCEffect.new(cc_effect.cc_type, final_duration, cc_effect.strength, cc_effect.source)
	
	if cc_effect.is_hard_cc:
		for existing_effect in active_cc_effects[node_path]:
			if existing_effect.is_hard_cc:
				if reduced_effect.strength > existing_effect.strength:
					active_cc_effects[node_path].erase(existing_effect)
					active_cc_effects[node_path].append(reduced_effect)
				return true
			else:
				active_cc_effects[node_path].erase(existing_effect)
	
	active_cc_effects[node_path].append(reduced_effect)
	
	if target.has_method("on_cc_applied"):
		target.on_cc_applied(reduced_effect)
	
	EventBus.emit_buff_added(target, cc_effect.source)
	
	return true

func has_immunity(target: Node, cc_effect: CCEffect) -> bool:
	if target.has_node("TalentSystem"):
		var talent_system: TalentSystem = target.get_node("TalentSystem")
		for talent_id in talent_system.get_active_talent_ids():
			var talent: TalentData = talent_system.get_talent(talent_id)
			if talent and talent.effect_type == "immunity":
				return true
	
	if target.has_node("CharacterStats"):
		var stats: CharacterStats = target.get_node("CharacterStats")
		var cc_resist: float = stats.get_stat("crowd_control_resist")
		if randf() < cc_resist:
			return true
	
	return false

func get_tenacity(target: Node) -> float:
	if target.has_node("CharacterStats"):
		var stats: CharacterStats = target.get_node("CharacterStats")
		return stats.get_stat("tenacity")
	return 0.0

func remove_cc(target: Node, cc_type: CCEffect.CCType = null):
	var node_path: String = str(target.get_path())
	if node_path not in active_cc_effects:
		return
	
	if cc_type:
		var to_remove: Array = []
		for effect in active_cc_effects[node_path]:
			if effect.cc_type == cc_type:
				to_remove.append(effect)
		
		for effect in to_remove:
			active_cc_effects[node_path].erase(effect)
			EventBus.emit_buff_removed(target, effect.source)
	else:
		for effect in active_cc_effects[node_path]:
			EventBus.emit_buff_removed(target, effect.source)
		active_cc_effects.erase(node_path)
	
	if target.has_method("on_cc_removed"):
		target.on_cc_removed()

func update_cc_effects(delta: float):
	var expired_paths: Array = []
	
	for node_path in active_cc_effects:
		var target: Node = get_node_or_null(node_path)
		if not target:
			expired_paths.append(node_path)
			continue
		
		var expired_effects: Array = []
		for effect in active_cc_effects[node_path]:
			effect.tick(delta)
			if effect.is_expired():
				expired_effects.append(effect)
		
		for effect in expired_effects:
			active_cc_effects[node_path].erase(effect)
			EventBus.emit_buff_removed(target, effect.source)
		
		if active_cc_effects[node_path].empty():
			expired_paths.append(node_path)
			if target.has_method("on_cc_removed"):
				target.on_cc_removed()
	
	for path in expired_paths:
		active_cc_effects.erase(path)

func is_cc_active(target: Node) -> bool:
	var node_path: String = str(target.get_path())
	return node_path in active_cc_effects and not active_cc_effects[node_path].empty()

func has_hard_cc(target: Node) -> bool:
	var node_path: String = str(target.get_path())
	if node_path not in active_cc_effects:
		return false
	
	for effect in active_cc_effects[node_path]:
		if effect.is_hard_cc:
			return true
	
	return false

func is_valid_node(node: Node) -> bool:
	return node and is_instance_valid(node)

func _process(delta: float):
	update_cc_effects(delta)
