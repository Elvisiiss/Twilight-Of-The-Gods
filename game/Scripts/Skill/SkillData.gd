extends Node

var skill_id: String = ""
var name: String = ""
var description: String = ""
var skill_type: String = ""
var damage_type: String = ""
var damage: float = 0.0
var mp_cost: float = 0.0
var cooldown: float = 0.0
var range: float = 0.0
var duration: float = 0.0
var effects: Dictionary = {}
var icon_path: String = ""
var level_requirement: int = 1
var class_requirement: String = ""

func _ready():
    pass

func _init(p_data: Dictionary):
    skill_id = p_data.get("id", "")
    name = p_data.get("name", "")
    description = p_data.get("description", "")
    skill_type = p_data.get("type", "")
    damage_type = p_data.get("damage_type", "")
    damage = p_data.get("damage", 0.0)
    mp_cost = p_data.get("mp_cost", 0.0)
    cooldown = p_data.get("cooldown", 0.0)
    range = p_data.get("range", 0.0)
    duration = p_data.get("duration", 0.0)
    effects = p_data.get("effects", {})
    icon_path = p_data.get("icon", "")
    level_requirement = p_data.get("level_requirement", 1)
    class_requirement = p_data.get("class", "")

func is_active() -> bool:
    return skill_type == "active"

func is_passive() -> bool:
    return skill_type == "passive"

func can_use(caster_level: int, caster_class: String) -> bool:
    if caster_level < level_requirement:
        return false
    if class_requirement != "" and class_requirement != caster_class:
        return false
    return true

func get_effect_value(effect_name: String) -> float:
    return effects.get(effect_name, 0.0)
