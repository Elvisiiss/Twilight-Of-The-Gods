extends Node

enum CCType { STUN, SLOW, FREEZE, FEAR, SILENCE, ROOT }

var active_cc_effects: Dictionary = {}

func _ready():
    active_cc_effects = {}

func apply_cc(target: Node, cc_type: CCType, duration: float, source: Node = null):
    if target.has_method("get_stat"):
        var crowd_control_resist = target.get_stat("crowd_control_resist")
        var tenacity = target.get_stat("tenacity")
        
        var total_resist = crowd_control_resist + tenacity
        var effective_duration = duration * (1 - total_resist)
        
        if effective_duration <= 0:
            return
        
        var cc_effect = CCEffect.new(cc_type, effective_duration, source)
        
        if not target in active_cc_effects:
            active_cc_effects[target] = []
        
        active_cc_effects[target].append(cc_effect)
        
        _apply_cc_effect(target, cc_effect)

func remove_cc(target: Node, cc_type: CCType = null):
    if not target in active_cc_effects:
        return
    
    if cc_type == null:
        for effect in active_cc_effects[target]:
            _remove_cc_effect(target, effect)
        active_cc_effects[target].clear()
        active_cc_effects.erase(target)
    else:
        var to_remove: Array = []
        for effect in active_cc_effects[target]:
            if effect.cc_type == cc_type:
                to_remove.append(effect)
        
        for effect in to_remove:
            _remove_cc_effect(target, effect)
            active_cc_effects[target].erase(effect)
        
        if active_cc_effects[target].empty():
            active_cc_effects.erase(target)

func update(delta: float):
    var to_remove: Array = []
    
    for target in active_cc_effects:
        var effects_to_remove: Array = []
        
        for effect in active_cc_effects[target]:
            effect.duration -= delta
            
            if effect.duration <= 0:
                effects_to_remove.append(effect)
        
        for effect in effects_to_remove:
            _remove_cc_effect(target, effect)
            active_cc_effects[target].erase(effect)
        
        if active_cc_effects[target].empty():
            to_remove.append(target)
    
    for target in to_remove:
        active_cc_effects.erase(target)

func is_cc_active(target: Node, cc_type: CCType = null) -> bool:
    if not target in active_cc_effects:
        return false
    
    if cc_type == null:
        return active_cc_effects[target].size() > 0
    
    for effect in active_cc_effects[target]:
        if effect.cc_type == cc_type:
            return true
    
    return false

func get_cc_duration(target: Node, cc_type: CCType) -> float:
    if not target in active_cc_effects:
        return 0.0
    
    for effect in active_cc_effects[target]:
        if effect.cc_type == cc_type:
            return effect.duration
    
    return 0.0

func _apply_cc_effect(target: Node, effect: CCEffect):
    match effect.cc_type:
        CCType.STUN:
            _apply_stun(target)
        CCType.SLOW:
            _apply_slow(target, 0.5)
        CCType.FREEZE:
            _apply_freeze(target)
        CCType.FEAR:
            _apply_fear(target)
        CCType.SILENCE:
            _apply_silence(target)
        CCType.ROOT:
            _apply_root(target)

func _remove_cc_effect(target: Node, effect: CCEffect):
    match effect.cc_type:
        CCType.STUN:
            _remove_stun(target)
        CCType.SLOW:
            _remove_slow(target)
        CCType.FREEZE:
            _remove_freeze(target)
        CCType.FEAR:
            _remove_fear(target)
        CCType.SILENCE:
            _remove_silence(target)
        CCType.ROOT:
            _remove_root(target)

func _apply_stun(target: Node):
    if target.has_method("set_stunned"):
        target.set_stunned(true)

func _remove_stun(target: Node):
    if target.has_method("set_stunned"):
        target.set_stunned(false)

func _apply_slow(target: Node, slow_amount: float):
    if target.has_method("add_modifier"):
        var modifier = StatModifier.new("move_speed", -slow_amount, StatModifier.ModifierType.MULTIPLICATIVE, "cc_slow")
        target.add_modifier(modifier)

func _remove_slow(target: Node):
    if target.has_method("remove_modifier"):
        target.remove_modifier("cc_slow")

func _apply_freeze(target: Node):
    if target.has_method("set_frozen"):
        target.set_frozen(true)

func _remove_freeze(target: Node):
    if target.has_method("set_frozen"):
        target.set_frozen(false)

func _apply_fear(target: Node):
    if target.has_method("set_fearing"):
        target.set_fearing(true)

func _remove_fear(target: Node):
    if target.has_method("set_fearing"):
        target.set_fearing(false)

func _apply_silence(target: Node):
    if target.has_method("set_silenced"):
        target.set_silenced(true)

func _remove_silence(target: Node):
    if target.has_method("set_silenced"):
        target.set_silenced(false)

func _apply_root(target: Node):
    if target.has_method("set_rooted"):
        target.set_rooted(true)

func _remove_root(target: Node):
    if target.has_method("set_rooted"):
        target.set_rooted(false)
