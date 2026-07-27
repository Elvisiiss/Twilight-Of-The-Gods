extends Node

enum ModifierType { ADDITIVE, MULTIPLICATIVE, PERCENTAGE }

var stat_name: String = ""
var value: float = 0.0
var modifier_type: ModifierType = ModifierType.ADDITIVE
var source: String = ""
var duration: float = 0.0
var is_permanent: bool = false
var icon_path: String = ""

func _ready():
    pass

func _init(p_stat_name: String, p_value: float, p_modifier_type: ModifierType, 
           p_source: String, p_duration: float = 0.0, p_is_permanent: bool = false):
    stat_name = p_stat_name
    value = p_value
    modifier_type = p_modifier_type
    source = p_source
    duration = p_duration
    is_permanent = p_is_permanent

func is_expired() -> bool:
    return not is_permanent and duration <= 0.0

func apply_to(base_value: float) -> float:
    match modifier_type:
        ModifierType.ADDITIVE:
            return base_value + value
        ModifierType.MULTIPLICATIVE:
            return base_value * (1 + value)
        ModifierType.PERCENTAGE:
            return base_value * (1 + value / 100)
    return base_value
