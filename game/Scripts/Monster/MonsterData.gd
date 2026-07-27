extends Node

var monster_id: String = ""
var name: String = ""
var description: String = ""
var rarity: String = ""
var level: int = 1
var hp: float = 100.0
var attack: float = 10.0
var armor: float = 0.0
var magic_resist: float = 0.0
var move_speed: float = 100.0
var exp_reward: float = 10.0
var drops: Array = []
var drop_chances: Array = []
var skills: Array = []
var icon_path: String = ""

func _ready():
    pass

func _init(p_data: Dictionary):
    monster_id = p_data.get("id", "")
    name = p_data.get("name", "")
    description = p_data.get("description", "")
    rarity = p_data.get("rarity", "")
    level = p_data.get("level", 1)
    hp = p_data.get("hp", 100.0)
    attack = p_data.get("attack", 10.0)
    armor = p_data.get("armor", 0.0)
    magic_resist = p_data.get("magic_resist", 0.0)
    move_speed = p_data.get("move_speed", 100.0)
    exp_reward = p_data.get("exp_reward", 10.0)
    drops = p_data.get("drops", [])
    drop_chances = p_data.get("drop_chance", [])
    skills = p_data.get("skills", [])
    icon_path = p_data.get("icon", "")

func is_boss() -> bool:
    return rarity == "boss"

func is_elite() -> bool:
    return rarity == "elite"

func get_rarity_color() -> Color:
    var colors = {
        "common": Color(0.8, 0.8, 0.8),
        "elite": Color(0.0, 1.0, 0.0),
        "black_iron": Color(0.5, 0.5, 0.5),
        "bronze": Color(0.8, 0.6, 0.2),
        "silver": Color(0.9, 0.9, 0.9),
        "gold": Color(1.0, 0.8, 0.0),
        "platinum": Color(0.8, 0.9, 0.9),
        "diamond": Color(0.5, 0.8, 1.0),
        "legendary": Color(1.0, 0.5, 0.8),
        "boss": Color(1.0, 0.2, 0.2)
    }
    return colors.get(rarity, Color(0.8, 0.8, 0.8))
