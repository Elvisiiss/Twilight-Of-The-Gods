extends KinematicBody2D

enum CharacterState {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	CAST,
	HURT,
	DEAD,
	DODGE
}

var state: CharacterState = CharacterState.IDLE
var character_stats: CharacterStats = null
var level_system: LevelSystem = null
var class_system: ClassSystem = null
var talent_system: TalentSystem = null
var attack_system: AttackSystem = null
var skill_manager: SkillManager = null

var movement_speed: float = 3.1
var attack_range: float = 100.0
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var last_attack_time: float = 0.0

func _ready():
	character_stats = CharacterStats.new()
	level_system = LevelSystem.new()
	class_system = ClassSystem.new()
	talent_system = TalentSystem.new()
	add_child(character_stats)
	add_child(level_system)
	add_child(class_system)
	add_child(talent_system)
	
	attack_system = AttackSystem.new()
	attack_system.setup(self)
	add_child(attack_system)
	
	skill_manager = SkillManager.new()
	add_child(skill_manager)

func _physics_process(delta: float):
	if state == CharacterState.DEAD:
		return
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	var input_vector: Vector2 = InputManager.get_movement_vector()
	
	if input_vector.length() > 0:
		if state != CharacterState.ATTACK and state != CharacterState.CAST:
			var speed: float = character_stats.get_stat("move_speed")
			input_vector *= speed
			move_and_slide(input_vector)
			state = CharacterState.WALK
			
			if input_vector.length() > speed * 0.8:
				state = CharacterState.RUN
	else:
		if state != CharacterState.ATTACK and state != CharacterState.CAST:
			state = CharacterState.IDLE
	
	process_combat_input(delta)
	update_animation()

func process_combat_input(delta: float):
	if InputManager.is_action_just_pressed("attack") and attack_cooldown <= 0:
		perform_attack()
	
	if InputManager.is_action_just_pressed("skill_1"):
		skill_manager.cast_skill("skill_1", get_target())
	if InputManager.is_action_just_pressed("skill_2"):
		skill_manager.cast_skill("skill_2", get_target())
	if InputManager.is_action_just_pressed("skill_3"):
		skill_manager.cast_skill("skill_3", get_target())
	if InputManager.is_action_just_pressed("skill_4"):
		skill_manager.cast_skill("skill_4", get_target())
	if InputManager.is_action_just_pressed("skill_5"):
		skill_manager.cast_skill("skill_5", get_target())
	if InputManager.is_action_just_pressed("dodge"):
		perform_dodge()

func perform_attack():
	state = CharacterState.ATTACK
	is_attacking = true
	
	var attack_speed: float = character_stats.get_stat("attack_speed")
	attack_cooldown = 1.0 / attack_speed
	
	attack_system.perform_attack(get_target())
	
	last_attack_time = OS.get_ticks_msec()
	
	for talent_id in talent_system.get_active_talent_ids():
		var talent: TalentData = talent_system.get_talent(talent_id)
		if talent and talent.is_active and talent.effect_type == "true_damage_percentage":
			talent_system.add_proficiency(talent_id, 1)

func perform_dodge():
	state = CharacterState.DODGE
	var dodge_distance: float = 100.0
	var direction: Vector2 = transform.x * dodge_distance
	move_and_slide(direction)
	state = CharacterState.IDLE

func get_target() -> Node:
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node = null
	var min_distance: float = INF
	
	for enemy in enemies:
		var distance: float = global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func take_damage(damage: float, damage_type: String):
	if state == CharacterState.DEAD:
		return
	
	var current_hp: float = character_stats.get_stat("hp")
	var new_hp: float = max(0, current_hp - damage)
	
	character_stats.set_base_stat("hp", new_hp)
	
	if new_hp <= 0:
		on_death()
	else:
		state = CharacterState.HURT
		get_tree().create_timer(0.2).connect("timeout", self, "_on_hurt_end")

func on_death():
	state = CharacterState.DEAD
	EventBus.emit_death(self, null)

func on_revive():
	state = CharacterState.IDLE
	character_stats.set_base_stat("hp", character_stats.get_stat("hp") * 0.5)

func _on_hurt_end():
	if state == CharacterState.HURT:
		state = CharacterState.IDLE

func update_animation():
	var sprite: Sprite = $Sprite
	if sprite:
		match state:
			CharacterState.IDLE:
				sprite.frame = 0
			CharacterState.WALK:
				sprite.frame = 1
			CharacterState.RUN:
				sprite.frame = 2
			CharacterState.ATTACK:
				sprite.frame = 3
			CharacterState.CAST:
				sprite.frame = 4
			CharacterState.HURT:
				sprite.frame = 5
			CharacterState.DEAD:
				sprite.frame = 6

func select_class(class_id: String):
	class_system.select_class(class_id)
	var class_data: ClassData = class_system.get_current_class()
	if class_data:
		character_stats.set_class_data(class_data)
		apply_class_bonuses(class_data)

func apply_class_bonuses(class_data: ClassData):
	for stat_name in class_data.attribute_bonus:
		var bonus: float = class_data.attribute_bonus[stat_name]
		character_stats.add_to_base_stat(stat_name, bonus)
