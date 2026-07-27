extends Node

var skills: Dictionary = {}
var skill_slots: Dictionary = {}
var cooldowns: Dictionary = {}
var event_bus: EventBus = null

func _ready():
    skills = {}
    skill_slots = {
        "skill_1": "",
        "skill_2": "",
        "skill_3": "",
        "skill_4": "",
        "skill_q": "",
        "skill_e": "",
        "skill_r": ""
    }
    cooldowns = {}

func init_skills(class_id: String):
    var class_skills = ClassSystem.get_class_skills(class_id)
    
    for i in range(min(class_skills.size(), 4)):
        var skill_id = class_skills[i]
        skill_slots["skill_" + str(i + 1)] = skill_id
    
    load_all_skill_data()

func load_all_skill_data():
    var data_manager = DataManager.new()
    data_manager.init()
    
    for slot in skill_slots:
        var skill_id = skill_slots[slot]
        if skill_id != "":
            skills[skill_id] = data_manager.get_skill(skill_id)
            cooldowns[skill_id] = 0.0

func set_event_bus(p_event_bus: EventBus):
    event_bus = p_event_bus

func cast_skill(slot: String, caster: Node):
    var skill_id = skill_slots.get(slot)
    if not skill_id or skill_id == "":
        return
    
    if cooldowns.get(skill_id, 0) > 0:
        return
    
    var skill_data = skills.get(skill_id, {})
    if skill_data.empty():
        return
    
    var mp_cost = skill_data.get("mp_cost", 0)
    if caster.has_method("get_stat"):
        var current_mp = caster.get_stat("mp")
        if current_mp < mp_cost:
            return
    
    if caster.has_method("add_to_base_stat"):
        caster.add_to_base_stat("mp", -mp_cost)
    
    _execute_skill(skill_id, skill_data, caster)
    
    var cooldown = skill_data.get("cooldown", 0)
    if cooldown > 0:
        cooldowns[skill_id] = cooldown
    
    if event_bus:
        event_bus.emit_skill_cast(caster, skill_id, null)

func _execute_skill(skill_id: String, skill_data: Dictionary, caster: Node):
    var damage_type = skill_data.get("damage_type", "")
    
    match damage_type:
        "physical", "magical":
            _execute_damage_skill(skill_data, caster)
        "buff":
            _execute_buff_skill(skill_data, caster)
        "movement":
            _execute_movement_skill(skill_data, caster)
        "heal":
            _execute_heal_skill(skill_data, caster)

func _execute_damage_skill(skill_data: Dictionary, caster: Node):
    var damage = skill_data.get("damage", 1.0)
    var count = skill_data.get("count", 1)
    var damage_type = skill_data.get("damage_type", "physical")
    
    var atk = 0.0
    if caster.has_method("get_stat"):
        atk = caster.get_stat("attack")
    
    var total_damage = atk * damage
    
    for i in range(count):
        _find_and_damage_target(caster, total_damage, damage_type)

func _execute_buff_skill(skill_data: Dictionary, caster: Node):
    var effects = skill_data.get("effects", {})
    var duration = skill_data.get("duration", 10.0)
    
    for stat_name in effects:
        var value = effects[stat_name]
        if caster.has_method("add_modifier"):
            var modifier = StatModifier.new(stat_name, value, StatModifier.ModifierType.MULTIPLICATIVE, skill_data.get("name"), duration)
            caster.add_modifier(modifier)

func _execute_movement_skill(skill_data: Dictionary, caster: Node):
    var distance = skill_data.get("distance", 500)
    
    if caster.has_method("get_global_position"):
        var direction = caster.get_global_position().normalized()
        var new_position = caster.get_global_position() + direction * distance
        if caster.has_method("set_global_position"):
            caster.set_global_position(new_position)

func _execute_heal_skill(skill_data: Dictionary, caster: Node):
    var heal_amount = skill_data.get("heal_amount", 0)
    if caster.has_method("add_to_base_stat"):
        caster.add_to_base_stat("hp", heal_amount)

func _find_and_damage_target(caster: Node, damage: float, damage_type: String):
    var target = _find_nearest_target(caster)
    if target and target.has_method("take_damage"):
        target.take_damage(damage, damage_type)

func _find_nearest_target(caster: Node) -> Node:
    if not caster.has_method("get_global_position"):
        return null
    
    var player_pos = caster.get_global_position()
    var nearest_target = null
    var nearest_distance = 99999
    
    for node in get_tree().get_nodes_in_group("monsters"):
        if node == caster:
            continue
        
        var target_pos = node.get_global_position()
        var distance = player_pos.distance_to(target_pos)
        
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_target = node
    
    return nearest_target

func update_cooldowns(delta: float):
    for skill_id in cooldowns:
        if cooldowns[skill_id] > 0:
            cooldowns[skill_id] -= delta
            if cooldowns[skill_id] < 0:
                cooldowns[skill_id] = 0

func get_cooldown(skill_id: String) -> float:
    return cooldowns.get(skill_id, 0.0)

func get_skill_data(skill_id: String) -> Dictionary:
    return skills.get(skill_id, {})

func get_skill_in_slot(slot: String) -> String:
    return skill_slots.get(slot, "")

func set_skill_in_slot(slot: String, skill_id: String):
    skill_slots[slot] = skill_id
    if skill_id != "" and not skill_id in skills:
        var data_manager = DataManager.new()
        data_manager.init()
        skills[skill_id] = data_manager.get_skill(skill_id)
        cooldowns[skill_id] = 0.0
