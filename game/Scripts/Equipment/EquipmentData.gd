extends Node

var item_id: String = ""
var name: String = ""
var description: String = ""
var item_type: String = ""
var slot: String = ""
var rarity: String = ""
var level_requirement: int = 1
var class_requirement: String = ""
var stats: Dictionary = {}
var effects: Array = []
var icon_path: String = ""
var is_unique: bool = false
var set_id: String = ""

func _ready():
    pass

func _init(p_data: Dictionary):
    item_id = p_data.get("id", "")
    name = p_data.get("name", "")
    description = p_data.get("description", "")
    item_type = p_data.get("type", "")
    slot = p_data.get("slot", "")
    rarity = p_data.get("rarity", "")
    level_requirement = p_data.get("level_requirement", 1)
    class_requirement = p_data.get("class", "")
    stats = p_data.get("stats", {})
    effects = p_data.get("effects", [])
    icon_path = p_data.get("icon", "")
    is_unique = p_data.get("unique", false)
    set_id = p_data.get("set", "")

func is_equipment() -> bool:
    return item_type == "equipment"

func is_consumable() -> bool:
    return item_type == "consumable"

func is_material() -> bool:
    return item_type == "material"

func get_stat_value(stat_name: String) -> float:
    return stats.get(stat_name, 0.0)

func has_stat(stat_name: String) -> bool:
    return stat_name in stats

func get_rarity_multiplier() -> float:
    var multipliers = {
        "common": 1.0,
        "elite": 2.0,
        "black_iron": 4.0,
        "bronze": 8.0,
        "silver": 16.0,
        "gold": 32.0,
        "platinum": 64.0,
        "diamond": 128.0,
        "legendary": 256.0,
        "epic": 512.0,
        "artifact": 1024.0,
        "super_artifact": 2048.0
    }
    return multipliers.get(rarity, 1.0)
