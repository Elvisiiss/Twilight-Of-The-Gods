extends Node

enum AIState {
	PATROL,
	CHASE,
	ATTACK,
	RETURN,
	DEAD
}

var state: AIState = AIState.PATROL
var monster_data: MonsterData = null
var monster_stats: MonsterStats = null
var hate_system: HateSystem = null
var target: Node = null
var home_position: Vector2 = Vector2.ZERO
var current_patrol_point: Vector2 = Vector2.ZERO
var attack_cooldown: float = 0.0
var attack_range: float = 50.0

func _ready():
	hate_system = HateSystem.new()
	add_child(hate_system)

func setup(monster_data: MonsterData, stats: MonsterStats):
	self.monster_data = monster_data
	self.monster_stats = stats
	home_position = get_parent().global_position
	current_patrol_point = get_random_patrol_point()
	attack_range = monster_data.aggro_range / 3

func _physics_process(delta: float):
	if state == AIState.DEAD:
		return
	
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	match state:
		AIState.PATROL:
			patrol(delta)
		AIState.CHASE:
			chase(delta)
		AIState.ATTACK:
			attack(delta)
		AIState.RETURN:
			return_to_home(delta)

func patrol(delta: float):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var distance_to_patrol: float = parent.global_position.distance_to(current_patrol_point)
	
	if distance_to_patrol < 10:
		current_patrol_point = get_random_patrol_point()
	
	var direction: Vector2 = (current_patrol_point - parent.global_position).normalized()
	var speed: float = monster_stats.get_stat("move_speed") * 0.5
	parent.move_and_slide(direction * speed)
	
	check_aggro()

func get_random_patrol_point() -> Vector2:
	var angle: float = rand_range(0, TAU)
	var radius: float = rand_range(0, monster_data.patrol_radius)
	return home_position + Vector2(cos(angle), sin(angle)) * radius

func check_aggro():
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var players: Array = get_tree().get_nodes_in_group("players")
	for player in players:
		var distance: float = parent.global_position.distance_to(player.global_position)
		if distance <= monster_data.aggro_range:
			hate_system.add_hate(player, 10.0)
			target = player
			state = AIState.CHASE
			return

func chase(delta: float):
	if not target or not is_instance_valid(target):
		state = AIState.RETURN
		return
	
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var distance: float = parent.global_position.distance_to(target.global_position)
	
	if distance > monster_data.chase_range:
		hate_system.clear_hate()
		state = AIState.RETURN
		return
	
	if distance <= attack_range:
		state = AIState.ATTACK
		return
	
	var direction: Vector2 = (target.global_position - parent.global_position).normalized()
	var speed: float = monster_stats.get_stat("move_speed")
	parent.move_and_slide(direction * speed)

func attack(delta: float):
	if not target or not is_instance_valid(target):
		state = AIState.CHASE
		return
	
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var distance: float = parent.global_position.distance_to(target.global_position)
	
	if distance > attack_range:
		state = AIState.CHASE
		return
	
	if attack_cooldown <= 0:
		perform_attack()
		attack_cooldown = 1.0 / monster_stats.get_stat("attack_speed")

func perform_attack():
	if not target or not target.has_method("take_damage"):
		return
	
	var damage: float = monster_stats.get_stat("attack")
	target.take_damage(damage, "monster_attack")
	
	hate_system.add_hate(target, 5.0)

func return_to_home(delta: float):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var distance: float = parent.global_position.distance_to(home_position)
	
	if distance < 10:
		state = AIState.PATROL
		current_patrol_point = get_random_patrol_point()
		return
	
	var direction: Vector2 = (home_position - parent.global_position).normalized()
	var speed: float = monster_stats.get_stat("move_speed") * 0.7
	parent.move_and_slide(direction * speed)

func on_damage(damage: float, attacker: Node):
	hate_system.add_hate(attacker, damage * 2)
	
	if state == AIState.PATROL:
		target = attacker
		state = AIState.CHASE

func on_death():
	state = AIState.DEAD
	hate_system.clear_hate()

func on_respawn():
	state = AIState.PATROL
	hate_system.clear_hate()
