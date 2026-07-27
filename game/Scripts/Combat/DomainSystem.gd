extends Node

enum DomainType {
	PLAYER_DOMAIN,
	ARENA_DOMAIN,
	BOSS_DOMAIN
}

var active_domains: Dictionary = {}

func _ready():
	pass

func create_domain(caster: Node, domain_type: DomainType, radius: float = 200.0):
	var domain_id: String = str(caster.get_path()) + "_domain"
	
	if domain_id in active_domains:
		destroy_domain(domain_id)
	
	var domain: Dictionary = {
		"id": domain_id,
		"caster": caster,
		"type": domain_type,
		"radius": radius,
		"position": caster.global_position,
		"effects": get_domain_effects(caster, domain_type),
		"duration": 10.0,
		"remaining_duration": 10.0
	}
	
	active_domains[domain_id] = domain
	
	EventBus.emit_domain_create(caster, domain_type)
	
	get_tree().create_timer(domain["duration"]).connect("timeout", self, "_on_domain_expire", [domain_id])

func get_domain_effects(caster: Node, domain_type: DomainType) -> Array:
	var effects: Array = []
	
	if caster.has_node("CharacterStats"):
		var stats: CharacterStats = caster.get_node("CharacterStats")
		
		match domain_type:
			DomainType.PLAYER_DOMAIN:
				effects = [
					{"type": "buff", "stat": "attack", "value": stats.get_stat("attack") * 0.1},
					{"type": "buff", "stat": "magic_power", "value": stats.get_stat("magic_power") * 0.1},
					{"type": "debuff", "stat": "attack", "value": -stats.get_stat("attack") * 0.05}
				]
			DomainType.ARENA_DOMAIN:
				effects = [
					{"type": "buff", "stat": "attack", "value": stats.get_stat("attack") * 0.2},
					{"type": "buff", "stat": "magic_power", "value": stats.get_stat("magic_power") * 0.2},
					{"type": "buff", "stat": "armor", "value": stats.get_stat("armor") * 0.1},
					{"type": "buff", "stat": "magic_resist", "value": stats.get_stat("magic_resist") * 0.1},
					{"type": "debuff", "stat": "attack", "value": -stats.get_stat("attack") * 0.1},
					{"type": "debuff", "stat": "move_speed", "value": -stats.get_stat("move_speed") * 0.2}
				]
			DomainType.BOSS_DOMAIN:
				effects = [
					{"type": "debuff", "stat": "attack", "value": -stats.get_stat("attack") * 0.15},
					{"type": "debuff", "stat": "move_speed", "value": -stats.get_stat("move_speed") * 0.3},
					{"type": "buff", "stat": "armor", "value": stats.get_stat("armor") * 0.5},
					{"type": "buff", "stat": "magic_resist", "value": stats.get_stat("magic_resist") * 0.5}
				]
	
	return effects

func update_domain(domain_id: String, delta: float):
	if domain_id not in active_domains:
		return
	
	var domain: Dictionary = active_domains[domain_id]
	domain["remaining_duration"] -= delta
	
	if domain["caster"].is_instance_valid():
		domain["position"] = domain["caster"].global_position
	
	apply_domain_effects(domain)

func apply_domain_effects(domain: Dictionary):
	var players: Array = get_tree().get_nodes_in_group("players")
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	
	for player in players:
		if player.global_position.distance_to(domain["position"]) <= domain["radius"]:
			for effect in domain["effects"]:
				if effect["type"] == "buff":
					apply_buff(player, effect)
				elif effect["type"] == "debuff":
					if player != domain["caster"]:
						apply_debuff(player, effect)
	
	for enemy in enemies:
		if enemy.global_position.distance_to(domain["position"]) <= domain["radius"]:
			for effect in domain["effects"]:
				if effect["type"] == "debuff":
					apply_debuff(enemy, effect)
				elif effect["type"] == "buff":
					if enemy == domain["caster"]:
						apply_buff(enemy, effect)

func apply_buff(target: Node, effect: Dictionary):
	if target.has_node("CharacterStats"):
		var stats: CharacterStats = target.get_node("CharacterStats")
		var modifier: StatModifier = StatModifier.new(effect["stat"], effect["value"], StatModifier.ModifierType.ADDITIVE, "domain", 0.1)
		stats.add_modifier(modifier)

func apply_debuff(target: Node, effect: Dictionary):
	if target.has_node("CharacterStats") or target.has_node("MonsterStats"):
		var stats: Node = target.get_node("CharacterStats") if target.has_node("CharacterStats") else target.get_node("MonsterStats")
		if stats and stats.has_method("add_stat"):
			stats.add_stat(effect["stat"], effect["value"])

func destroy_domain(domain_id: String):
	if domain_id in active_domains:
		var domain: Dictionary = active_domains[domain_id]
		EventBus.emit_domain_destroy(domain["caster"])
		active_domains.erase(domain_id)

func _on_domain_expire(domain_id: String):
	destroy_domain(domain_id)

func _process(delta: float):
	for domain_id in active_domains:
		update_domain(domain_id, delta)
