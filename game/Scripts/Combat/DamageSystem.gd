extends Node

enum DamageType { PHYSICAL, MAGICAL, TRUE, PERCENTAGE }

func _ready():
    pass

func calculate_damage(attacker: Node, target: Node, base_damage: float, damage_type: DamageType) -> float:
    var final_damage = base_damage
    
    match damage_type:
        DamageType.PHYSICAL:
            final_damage = _calculate_physical_damage(attacker, target, base_damage)
        DamageType.MAGICAL:
            final_damage = _calculate_magical_damage(attacker, target, base_damage)
        DamageType.TRUE:
            final_damage = base_damage
        DamageType.PERCENTAGE:
            final_damage = _calculate_percentage_damage(target, base_damage)
    
    return final_damage

func _calculate_physical_damage(attacker: Node, target: Node, base_damage: float) -> float:
    var armor = 0.0
    var physical_penetration = 0.0
    
    if target.has_method("get_stat"):
        armor = target.get_stat("armor")
    
    if attacker.has_method("get_stat"):
        physical_penetration = attacker.get_stat("physical_penetration")
    
    var effective_armor = armor * (1 - physical_penetration)
    var damage_reduction = effective_armor / (effective_armor + 100)
    
    return base_damage * (1 - damage_reduction)

func _calculate_magical_damage(attacker: Node, target: Node, base_damage: float) -> float:
    var magic_resist = 0.0
    var magic_penetration = 0.0
    
    if target.has_method("get_stat"):
        magic_resist = target.get_stat("magic_resist")
    
    if attacker.has_method("get_stat"):
        magic_penetration = attacker.get_stat("magic_penetration")
    
    var effective_magic_resist = magic_resist * (1 - magic_penetration)
    var damage_reduction = effective_magic_resist / (effective_magic_resist + 100)
    
    return base_damage * (1 - damage_reduction)

func _calculate_percentage_damage(target: Node, percentage: float) -> float:
    var max_hp = 1.0
    if target.has_method("get_stat"):
        max_hp = target.get_stat("hp")
    
    return max_hp * (percentage / 100.0)

func calculate_crit_damage(base_damage: float, attacker: Node) -> float:
    var crit_rate = 0.0
    var crit_damage = 2.0
    
    if attacker.has_method("get_stat"):
        crit_rate = attacker.get_stat("crit_rate")
        crit_damage = attacker.get_stat("crit_damage")
    
    var is_crit = rand_range(0, 1) < crit_rate
    
    if is_crit:
        return base_damage * crit_damage, true
    
    return base_damage, false

func calculate_lifesteal(damage_dealt: float, attacker: Node) -> float:
    var lifesteal = 0.0
    
    if attacker.has_method("get_stat"):
        lifesteal = attacker.get_stat("lifesteal")
    
    return damage_dealt * lifesteal

func calculate_thorns_damage(damage_taken: float, target: Node) -> float:
    var thorns = 0.0
    
    if target.has_method("get_stat"):
        thorns = target.get_stat("thorns")
    
    return damage_taken * thorns
