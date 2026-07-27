extends MonsterAI

enum BossPhase {
	PHASE_1,
	PHASE_2,
	PHASE_3
}

var boss_phase: BossPhase = BossPhase.PHASE_1
var phase_transitions: Dictionary = {}
var mechanics: Array = []
var mechanic_cooldowns: Dictionary = {}
var enrage_threshold: float = 0.3
var is_enraged: bool = false

func _ready():
	hate_system = HateSystem.new()
	add_child(hate_system)

func setup(monster_data: MonsterData, stats: MonsterStats):
	super.setup(monster_data, stats)
	phase_transitions = {
		BossPhase.PHASE_1: 1.0,
		BossPhase.PHASE_2: 0.66,
		BossPhase.PHASE_3: 0.33
	}
	mechanics = monster_data.boss_mechanics

func _physics_process(delta: float):
	if state == AIState.DEAD:
		return
	
	check_phase()
	check_enrage()
	
	super._physics_process(delta)

func check_phase():
	var current_hp: float = monster_stats.get_stat("hp")
	var max_hp: float = monster_stats.get_stat("hp")
	
	for phase in phase_transitions:
		var threshold: float = phase_transitions[phase]
		if current_hp / max_hp <= threshold and boss_phase < phase:
			boss_phase = phase
			trigger_phase_change()
			return

func trigger_phase_change():
	match boss_phase:
		BossPhase.PHASE_2:
			monster_stats.add_stat("attack", monster_stats.get_stat("attack") * 0.5)
			monster_stats.add_stat("attack_speed", monster_stats.get_stat("attack_speed") * 0.3)
		BossPhase.PHASE_3:
			monster_stats.add_stat("attack", monster_stats.get_stat("attack") * 0.5)
			monster_stats.add_stat("attack_speed", monster_stats.get_stat("attack_speed") * 0.5)
	
	EventBus.emit_boss_phase_change(get_parent(), boss_phase)

func check_enrage():
	var current_hp: float = monster_stats.get_stat("hp")
	var max_hp: float = monster_stats.get_stat("hp")
	
	if current_hp / max_hp <= enrage_threshold and not is_enraged:
		is_enraged = true
		trigger_enrage()

func trigger_enrage():
	monster_stats.add_stat("attack", monster_stats.get_stat("attack") * 1.0)
	monster_stats.add_stat("attack_speed", monster_stats.get_stat("attack_speed") * 1.0)
	
	EventBus.emit_boss_enrage(get_parent())

func attack(delta: float):
	super.attack(delta)
	
	for mechanic in mechanics:
		if not mechanic_cooldowns.has(mechanic["id"]):
			mechanic_cooldowns[mechanic["id"]] = 0.0
		
		if mechanic_cooldowns[mechanic["id"]] <= 0:
			use_mechanic(mechanic)
			mechanic_cooldowns[mechanic["id"]] = mechanic.get("cooldown", 10.0)
	
	for mechanic_id in mechanic_cooldowns:
		mechanic_cooldowns[mechanic_id] -= delta

func use_mechanic(mechanic: Dictionary):
	match mechanic["type"]:
		"aoe":
			execute_aoe_attack(mechanic)
		"cleave":
			execute_cleave(mechanic)
		"summon":
			execute_summon(mechanic)
		"charge":
			execute_charge(mechanic)
		"debuff":
			execute_debuff(mechanic)

func execute_aoe_attack(mechanic: Dictionary):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var radius: float = mechanic.get("radius", 150.0)
	var damage: float = mechanic.get("damage", 100.0) * monster_stats.get_stat("attack") * 0.1
	
	var players: Array = get_tree().get_nodes_in_group("players")
	for player in players:
		if parent.global_position.distance_to(player.global_position) <= radius:
			if player.has_method("take_damage"):
				player.take_damage(damage, "boss_aoe")
			hate_system.add_hate(player, damage)

func execute_cleave(mechanic: Dictionary):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	if not target or not is_instance_valid(target):
		return
	
	var damage: float = mechanic.get("damage", 200.0) * monster_stats.get_stat("attack") * 0.15
	
	if target.has_method("take_damage"):
		target.take_damage(damage, "boss_cleave")
	hate_system.add_hate(target, damage)

func execute_summon(mechanic: Dictionary):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	var summon_count: int = mechanic.get("count", 3)
	var monster_id: String = mechanic.get("monster_id", "")
	
	for i in range(summon_count):
		var monster_scene: PackedScene = load("res://Scenes/Monster/" + monster_id + ".tscn")
		if monster_scene:
			var monster: Node = monster_scene.instance()
			var offset: Vector2 = Vector2(rand_range(-100, 100), rand_range(-100, 100))
			monster.global_position = parent.global_position + offset
			get_tree().root.add_child(monster)

func execute_charge(mechanic: Dictionary):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	if not target or not is_instance_valid(target):
		return
	
	var charge_speed: float = mechanic.get("speed", 20.0)
	var damage: float = mechanic.get("damage", 150.0) * monster_stats.get_stat("attack") * 0.1
	
	var direction: Vector2 = (target.global_position - parent.global_position).normalized()
	parent.move_and_slide(direction * charge_speed)
	
	if parent.global_position.distance_to(target.global_position) <= 30:
		if target.has_method("take_damage"):
			target.take_damage(damage, "boss_charge")
		hate_system.add_hate(target, damage)

func execute_debuff(mechanic: Dictionary):
	var parent: Node2D = get_parent() as Node2D
	if not parent:
		return
	
	if not target or not is_instance_valid(target):
		return
	
	var debuff_type: String = mechanic.get("debuff_type", "slow")
	var duration: float = mechanic.get("duration", 5.0)
	
	var cc_system: CCSystem = get_node_or_null("/root/CCSystem")
	if cc_system:
		var cc_type: int = CCEffect.CCType.SLOW
		if debuff_type == "silence":
			cc_type = CCEffect.CCType.SILENCE
		elif debuff_type == "blind":
			cc_type = CCEffect.CCType.BLIND
		
		var cc_effect: CCEffect = CCEffect.new(cc_type, duration, 0.5)
		cc_system.apply_cc(target, cc_effect)
