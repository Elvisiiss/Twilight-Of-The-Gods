extends KinematicBody2D

enum AIState { IDLE, PATROL, CHASE, ATTACK, RETURN }

var ai_state: AIState = AIState.IDLE
var monster_data: Dictionary = {}
var target: Node = null
var current_hp: float = 0.0
var max_hp: float = 0.0
var attack: float = 0.0
var armor: float = 0.0
var magic_resist: float = 0.0
var exp_reward: float = 0.0

var move_speed: float = 100.0
var attack_range: float = 100.0
var chase_range: float = 300.0
var patrol_points: Array = []
var current_patrol_index: int = 0
var attack_cooldown: float = 0.0
var last_attack_time: float = 0.0
var home_position: Vector2 = Vector2.ZERO

onready var sprite = $MonsterSprite
onready var collision_shape = $CollisionShape2D

func _ready():
    set_physics_process(true)
    set_process(true)
    home_position = global_position

func init_monster(data: Dictionary):
    monster_data = data
    max_hp = data.get("hp", 100)
    current_hp = max_hp
    attack = data.get("attack", 10)
    armor = data.get("armor", 0)
    magic_resist = data.get("magic_resist", 0)
    exp_reward = data.get("exp_reward", 10)
    move_speed = data.get("move_speed", 100)
    
    var patrol_radius = 100.0
    for i in range(4):
        var angle = (i / 4.0) * PI * 2
        var point = home_position + Vector2(cos(angle), sin(angle)) * patrol_radius
        patrol_points.append(point)

func _physics_process(delta: float):
    if current_hp <= 0:
        return
    
    _update_state(delta)
    _execute_state(delta)

func _update_state(delta: float):
    var player = _find_player()
    
    if player:
        var distance = global_position.distance_to(player.global_position)
        
        if distance <= attack_range:
            ai_state = AIState.ATTACK
            target = player
        elif distance <= chase_range:
            ai_state = AIState.CHASE
            target = player
        else:
            if ai_state == AIState.CHASE or ai_state == AIState.ATTACK:
                ai_state = AIState.RETURN
            else:
                ai_state = AIState.PATROL
    else:
        if ai_state == AIState.CHASE or ai_state == AIState.ATTACK:
            ai_state = AIState.RETURN
        else:
            ai_state = AIState.PATROL

func _execute_state(delta: float):
    match ai_state:
        AIState.IDLE:
            _do_idle(delta)
        AIState.PATROL:
            _do_patrol(delta)
        AIState.CHASE:
            _do_chase(delta)
        AIState.ATTACK:
            _do_attack(delta)
        AIState.RETURN:
            _do_return(delta)

func _do_idle(delta: float):
    pass

func _do_patrol(delta: float):
    if patrol_points.empty():
        return
    
    var target_point = patrol_points[current_patrol_index]
    var direction = (target_point - global_position).normalized()
    var velocity = direction * move_speed
    
    move_and_slide(velocity, Vector2.ZERO)
    
    if global_position.distance_to(target_point) < 10:
        current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
    
    if sprite:
        sprite.flip_h = direction.x < 0

func _do_chase(delta: float):
    if not target or not is_instance_valid(target):
        ai_state = AIState.RETURN
        return
    
    var direction = (target.global_position - global_position).normalized()
    var velocity = direction * move_speed * 1.2
    
    move_and_slide(velocity, Vector2.ZERO)
    
    if sprite:
        sprite.flip_h = direction.x < 0

func _do_attack(delta: float):
    if not target or not is_instance_valid(target):
        ai_state = AIState.PATROL
        return
    
    var now = OS.get_ticks_msec() / 1000.0
    if now - last_attack_time >= attack_cooldown:
        last_attack_time = now
        
        if target.has_method("take_damage"):
            target.take_damage(attack, "physical")
        
        attack_cooldown = 1.0

func _do_return(delta: float):
    var direction = (home_position - global_position).normalized()
    var velocity = direction * move_speed
    
    move_and_slide(velocity, Vector2.ZERO)
    
    if global_position.distance_to(home_position) < 10:
        ai_state = AIState.PATROL
    
    if sprite:
        sprite.flip_h = direction.x < 0

func _find_player() -> Node:
    for node in get_tree().get_nodes_in_group("players"):
        return node
    return null

func take_damage(damage: float, damage_type: String):
    if current_hp <= 0:
        return
    
    var actual_damage = damage
    
    match damage_type:
        "physical":
            actual_damage = damage * (1 - armor / (armor + 100))
        "magical":
            actual_damage = damage * (1 - magic_resist / (magic_resist + 100))
        "true":
            pass
        "percentage":
            actual_damage = max_hp * (damage / 100.0)
    
    current_hp = max(0, current_hp - actual_damage)
    
    if current_hp <= 0:
        die()

func die():
    queue_free()
    
    var player = _find_player()
    if player and player.has_method("gain_experience"):
        player.gain_experience(exp_reward)
    
    _drop_items()

func _drop_items():
    var drops = monster_data.get("drops", [])
    var drop_chances = monster_data.get("drop_chance", [])
    
    for i in range(drops.size()):
        var drop_id = drops[i]
        var chance = drop_chances[i] if i < drop_chances.size() else 0.1
        
        if rand_range(0, 1) < chance:
            var data_manager = DataManager.new()
            data_manager.init()
            var item_data = data_manager.get_item(drop_id)
            
            var player = _find_player()
            if player and player.has_method("add_item"):
                player.add_item(item_data)

func get_hp_percentage() -> float:
    if max_hp <= 0:
        return 0.0
    return (current_hp / max_hp) * 100.0

func get_max_hp() -> float:
    return max_hp

func get_current_hp() -> float:
    return current_hp
