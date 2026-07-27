extends KinematicBody2D

var monster_data: Dictionary = {}
var max_hp: float = 100.0
var current_hp: float = 100.0
var attack: float = 10.0
var armor: float = 0.0
var magic_resist: float = 0.0
var exp_reward: float = 10.0
var drops: Array = []
var drop_chance: Array = []

var state: String = "idle"
var target: Node = null
var move_speed: float = 100.0
var attack_range: float = 100.0
var aggro_range: float = 300.0
var patrol_points: Array = []
var current_patrol_index: int = 0
var attack_timer: float = 0.0
var attack_cooldown: float = 1.0

var is_alive: bool = true

onready var sprite = $Sprite

func _ready():
    add_to_group("monsters")
    state = "idle"

func init_monster(data: Dictionary):
    monster_data = data
    max_hp = data.get("hp", 100.0)
    current_hp = max_hp
    attack = data.get("attack", 10.0)
    armor = data.get("armor", 0.0)
    magic_resist = data.get("magic_resist", 0.0)
    exp_reward = data.get("exp_reward", 10.0)
    drops = data.get("drops", [])
    drop_chance = data.get("drop_chance", [])
    move_speed = data.get("move_speed", 100.0)
    
    _setup_patrol_points()

func _setup_patrol_points():
    var start_x = global_position.x - 100
    var start_y = global_position.y - 50
    patrol_points = [
        Vector2(start_x, start_y),
        Vector2(start_x + 200, start_y),
        Vector2(start_x + 200, start_y + 100),
        Vector2(start_x, start_y + 100)
    ]

func _physics_process(delta: float):
    if not is_alive:
        return
    
    _update_state(delta)
    _execute_state(delta)
    _update_attack_timer(delta)

func _update_state(delta: float):
    if state == "idle" or state == "patrol":
        _check_aggro()
    elif state == "chase":
        _check_target_distance()
    elif state == "attack":
        _check_target_in_range()

func _execute_state(delta: float):
    match state:
        "idle":
            _idle()
        "patrol":
            _patrol(delta)
        "chase":
            _chase(delta)
        "attack":
            _perform_attack(delta)

func _check_aggro():
    var player = _find_player()
    if player:
        var distance = global_position.distance_to(player.global_position)
        if distance <= aggro_range:
            target = player
            state = "chase"

func _check_target_distance():
    if not target or not is_instance_valid(target):
        state = "patrol"
        return
    
    var distance = global_position.distance_to(target.global_position)
    if distance > aggro_range:
        state = "patrol"
        target = null
    elif distance <= attack_range:
        state = "attack"

func _check_target_in_range():
    if not target or not is_instance_valid(target):
        state = "patrol"
        return
    
    var distance = global_position.distance_to(target.global_position)
    if distance > attack_range:
        state = "chase"

func _idle():
    pass

func _patrol(delta: float):
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

func _chase(delta: float):
    if not target or not is_instance_valid(target):
        state = "patrol"
        return
    
    var direction = (target.global_position - global_position).normalized()
    var velocity = direction * move_speed
    
    move_and_slide(velocity, Vector2.ZERO)
    
    if sprite:
        sprite.flip_h = direction.x < 0

func _perform_attack(delta: float):
    if not target or not is_instance_valid(target):
        state = "patrol"
        return
    
    if attack_timer <= 0:
        var damage = attack
        if target.has_method("take_damage"):
            target.take_damage(damage, "physical")
        
        attack_timer = attack_cooldown
        
        var direction = (target.global_position - global_position).normalized()
        if sprite:
            sprite.flip_h = direction.x < 0

func _update_attack_timer(delta: float):
    if attack_timer > 0:
        attack_timer -= delta

func _find_player() -> Node:
    for node in get_tree().get_nodes_in_group("player"):
        return node
    return null

func take_damage(damage: float, damage_type: String = "physical"):
    if not is_alive:
        return
    
    var actual_damage = damage
    
    match damage_type:
        "physical":
            actual_damage = damage * (1.0 - armor / (armor + 100))
        "magical":
            actual_damage = damage * (1.0 - magic_resist / (magic_resist + 100))
        "true":
            pass
        "percentage":
            actual_damage = max_hp * (damage / 100.0)
    
    actual_damage = max(1.0, actual_damage)
    current_hp -= actual_damage
    
    if current_hp <= 0:
        die()

func die():
    is_alive = false
    
    _drop_items()
    _give_exp()
    
    queue_free()

func _drop_items():
    for i in range(drops.size()):
        var drop_id = drops[i]
        var chance = drop_chance[i] if i < drop_chance.size() else 0.3
        
        if rand_range(0, 1) < chance:
            var data_manager = DataManager.new()
            data_manager.init()
            var item_data = data_manager.get_item(drop_id)
            
            if item_data:
                _spawn_item(item_data)

func _spawn_item(item_data: Dictionary):
    var item = Node2D.new()
    item.name = "DropItem_" + item_data.get("id", "")
    item.global_position = global_position
    add_child(item)

func _give_exp():
    var player = _find_player()
    if player and player.has_method("gain_experience"):
        player.gain_experience(exp_reward)

func get_hp_percentage() -> float:
    return (current_hp / max_hp) * 100.0