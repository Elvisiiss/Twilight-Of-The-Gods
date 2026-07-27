extends KinematicBody2D

var speed: float = 300.0
var velocity: Vector2 = Vector2.ZERO

var character_stats: CharacterStats = null
var skill_manager: SkillManager = null
var inventory: InventorySystem = null
var level_system: LevelSystem = null
var talent_system: TalentSystem = null
var damage_system: DamageSystem = null

var is_alive: bool = true
var is_in_combat: bool = false
var combat_timer: float = 0.0
var last_attack_time: float = 0.0

var current_class: String = "archer"
var talents: Array = []

onready var sprite = $PlayerSprite

func _ready():
	character_stats = CharacterStats.new()
	add_child(character_stats)
	
	skill_manager = SkillManager.new()
	add_child(skill_manager)
	
	inventory = InventorySystem.new()
	add_child(inventory)
	
	level_system = LevelSystem.new()
	add_child(level_system)
	
	talent_system = TalentSystem.new()
	add_child(talent_system)
	
	damage_system = DamageSystem.new()
	add_child(damage_system)

func init_player():
	character_stats.initialize_base_stats()
	level_system.set_level(1)
	
	var class_data = ClassSystem.get_class_data(current_class)
	character_stats.set_class_data(class_data)
	
	skill_manager.init_skills(current_class)
	
	_talent_system = get_parent().get_talent_system() if get_parent().has_method("get_talent_system") else null
	
	_event_bus = get_parent().get_event_bus() if get_parent().has_method("get_event_bus") else null
	if _event_bus:
		skill_manager.set_event_bus(_event_bus)
	
	_initialize_talents()

func _initialize_talents():
	talent_system.equip_talent("heavenly_punishment_hand", 2)
	talent_system.equip_talent("death_samsara", 1)
	
	for talent_id in talent_system.get_equipped_talents():
		var talent = talent_system.get_talent(talent_id)
		if talent:
			_apply_talent_effects(talent)

func _apply_talent_effects(talent_data: Dictionary):
	var talent_id = talent_data.get("id", "")
	
	if talent_id == "heavenly_punishment_hand":
		var star = talent_data.get("current_star", 1)
		var effects = talent_data.get("star_effects", {}).get(star, {})
		if effects:
			var modifier = StatModifier.new("true_damage", effects.get("true_damage_percent", 0.0), 
				StatModifier.ModifierType.MULTIPLICATIVE, "talent_" + talent_id, 0, true)
			character_stats.add_modifier(modifier)
	
	if talent_id == "death_samsara":
		var star = talent_data.get("current_star", 1)
		var effects = talent_data.get("star_effects", {}).get(star, {})
		if effects:
			var modifier = StatModifier.new("crit_rate", effects.get("kill_chance", 0.0), 
				StatModifier.ModifierType.ADDITIVE, "talent_" + talent_id, 0, true)
			character_stats.add_modifier(modifier)

func _physics_process(delta: float):
	if not is_alive:
		return
	
	_handle_movement(delta)
	_handle_combat_state(delta)
	_update_stats(delta)
	_handle_auto_attack(delta)

func _handle_movement(delta: float):
	var input_dir: Vector2 = Vector2.ZERO
	
	if Input.is_key_pressed(Key.KEY_A) or Input.is_key_pressed(Key.KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(Key.KEY_D) or Input.is_key_pressed(Key.KEY_RIGHT):
		input_dir.x += 1
	if Input.is_key_pressed(Key.KEY_W) or Input.is_key_pressed(Key.KEY_UP):
		input_dir.y -= 1
	if Input.is_key_pressed(Key.KEY_S) or Input.is_key_pressed(Key.KEY_DOWN):
		input_dir.y += 1
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var move_speed = character_stats.get_stat("move_speed") * 100
		velocity = input_dir * move_speed
		sprite.flip_h = input_dir.x < 0
	else:
		velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity, Vector2.ZERO)

func _handle_combat_state(delta: float):
	if is_in_combat:
		combat_timer += delta
		if combat_timer >= 5.0:
			is_in_combat = false
			combat_timer = 0.0

func _update_stats(delta: float):
	character_stats.update_modifiers(delta)
	skill_manager.update_cooldowns(delta)

func _handle_auto_attack(delta: float):
	var attack_speed = character_stats.get_stat("attack_speed")
	if attack_speed <= 0:
		return
	
	var attack_interval = 1.0 / attack_speed
	last_attack_time += delta
	
	if last_attack_time >= attack_interval:
		last_attack_time = 0.0
		var target = _find_nearest_target()
		if target:
			attack(target)

func _input(event: InputEvent):
	if not is_alive:
		return
	
	if event is InputEventKey and event.pressed:
		if event.scancode == Key.KEY_ESCAPE:
			var game_manager = get_parent()
			if game_manager and game_manager.has_method("toggle_pause"):
				game_manager.toggle_pause()
		else:
			_handle_skill_input(event)

func _handle_skill_input(event: InputEventKey):
	var key_map = {
		Key.KEY_1: "skill_1",
		Key.KEY_2: "skill_2",
		Key.KEY_3: "skill_3",
		Key.KEY_4: "skill_4",
		Key.KEY_Q: "skill_q",
		Key.KEY_E: "skill_e",
		Key.KEY_R: "skill_r"
	}
	
	var skill_slot = key_map.get(event.scancode)
	if skill_slot:
		skill_manager.cast_skill(skill_slot, self)

func take_damage(damage: float, damage_type: String = "physical"):
	if not is_alive:
		return
	
	var actual_damage = damage
	
	match damage_type:
		"physical":
			var armor = character_stats.get_stat("armor")
			actual_damage = damage * (1.0 - armor / (armor + 100))
		"magical":
			var magic_resist = character_stats.get_stat("magic_resist")
			actual_damage = damage * (1.0 - magic_resist / (magic_resist + 100))
		"true":
			pass
		"percentage":
			actual_damage = character_stats.get_stat("max_hp") * (damage / 100.0)
	
	actual_damage = max(1.0, actual_damage)
	
	character_stats.take_damage(actual_damage)
	
	if _event_bus:
		_event_bus.emit_damage(self, null, actual_damage, damage_type)
	
	if character_stats.get_stat("hp") <= 0:
		die()

func die():
	is_alive = true
	character_stats.heal(character_stats.get_stat("max_hp"))
	
	if _event_bus:
		_event_bus.emit_death(self, null)

func respawn():
	is_alive = true
	character_stats.heal(character_stats.get_stat("max_hp"))
	position = Vector2(400, 300)

func attack(target: Node):
	var atk = character_stats.get_stat("attack")
	var crit_rate = character_stats.get_stat("crit_rate")
	var crit_damage = character_stats.get_stat("crit_damage")
	var lifesteal = character_stats.get_stat("lifesteal")
	var true_damage = character_stats.get_stat("true_damage")
	
	var is_crit = rand_range(0, 1) < crit_rate
	var base_damage = atk * (crit_damage if is_crit else 1.0)
	
	var final_damage = base_damage
	if true_damage > 0:
		final_damage += character_stats.get_stat("max_hp") * true_damage
	
	if target.has_method("take_damage"):
		target.take_damage(final_damage, "physical")
	
	if lifesteal > 0:
		var heal_amount = final_damage * lifesteal
		character_stats.heal(heal_amount)
	
	if _event_bus:
		_event_bus.emit_damage(self, target, final_damage, "physical")
	
	is_in_combat = true
	combat_timer = 0.0

func gain_experience(exp: float):
	level_system.add_experience(exp)
	if level_system.should_level_up():
		level_up()

func level_up():
	level_system.level_up()
	var free_points = 5
	character_stats.add_free_attribute_points(free_points)
	
	if _event_bus:
		_event_bus.emit_level_up(self, level_system.get_level())

func _find_nearest_target() -> Node:
	var player_pos = global_position
	var nearest_target = null
	var nearest_distance = 500
	
	for node in get_tree().get_nodes_in_group("monsters"):
		if node == self:
			continue
		
		var target_pos = node.global_position
		var distance = player_pos.distance_to(target_pos)
		
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = node
	
	return nearest_target

func get_stat(stat_name: String) -> float:
	return character_stats.get_stat(stat_name)

func add_to_base_stat(stat_name: String, amount: float):
	character_stats.add_to_base_stat(stat_name, amount)

func add_modifier(modifier: StatModifier):
	character_stats.add_modifier(modifier)