extends Node

var owner: Node = null
var attack_anim_length: float = 0.5
var is_attacking: bool = false
var projectile_scene: PackedScene = null

func setup(owner: Node):
	self.owner = owner

func perform_attack(target: Node = null):
	if is_attacking or not owner:
		return
	
	is_attacking = true
	
	var stats: CharacterStats = owner.get_node("CharacterStats") if owner.has_node("CharacterStats") else null
	if not stats:
		return
	
	var attack_damage: float = stats.get_stat("attack")
	var lifesteal: float = stats.get_stat("lifesteal")
	var attack_speed: float = stats.get_stat("attack_speed")
	
	var damage_data: DamageData = DamageData.create(owner, target, attack_damage, DamageData.DamageType.PHYSICAL)
	damage_data.lifesteal = lifesteal
	damage_data.source_id = "basic_attack"
	
	if target:
		var is_crit: bool = DamageSystem.check_crit(stats, target.get_node("CharacterStats"))
		damage_data.is_crit = is_crit
		if is_crit:
			damage_data.crit_multiplier = DamageSystem.get_crit_multiplier(stats)
		
		DamageSystem.apply_damage(damage_data)
		
		var attack_range: float = stats.get_stat("attack_speed") * 50
		if owner.global_position.distance_to(target.global_position) > attack_range:
			shoot_projectile(target)
		else:
			melee_attack(target)
	
	get_tree().create_timer(1.0 / attack_speed).connect("timeout", self, "_on_attack_end")

func shoot_projectile(target: Node):
	if not projectile_scene:
		return
	
	var projectile: Node = ObjectPool.get_object("projectiles")
	if not projectile:
		projectile = projectile_scene.instance()
	
	projectile.global_position = owner.global_position
	projectile.set_target(target)
	projectile.set_damage_data(DamageData.create(owner, target, owner.get_node("CharacterStats").get_stat("attack"), DamageData.DamageType.PHYSICAL))
	
	get_tree().root.add_child(projectile)

func melee_attack(target: Node):
	if target and target.has_method("take_damage"):
		var damage: float = owner.get_node("CharacterStats").get_stat("attack")
		target.take_damage(damage, "melee")

func _on_attack_end():
	is_attacking = false
