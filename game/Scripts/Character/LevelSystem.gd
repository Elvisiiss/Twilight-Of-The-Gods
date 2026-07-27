extends Node

var level: int = 1
var experience: float = 0.0
var experience_for_next_level: float = 100.0
var free_attribute_points: int = 0

func _ready():
    level = 1
    experience = 0.0
    calculate_exp_for_next_level()

func get_level() -> int:
    return level

func set_level(new_level: int):
    level = new_level
    experience = 0.0
    free_attribute_points = (new_level - 1) * 5
    calculate_exp_for_next_level()

func get_experience() -> float:
    return experience

func get_experience_for_next_level() -> float:
    return experience_for_next_level

func get_experience_percentage() -> float:
    if experience_for_next_level <= 0:
        return 100.0
    return (experience / experience_for_next_level) * 100.0

func get_free_attribute_points() -> int:
    return free_attribute_points

func add_experience(exp: float):
    experience += exp
    while experience >= experience_for_next_level:
        experience -= experience_for_next_level
        level_up()

func should_level_up() -> bool:
    return experience >= experience_for_next_level

func level_up():
    level += 1
    free_attribute_points += 5
    calculate_exp_for_next_level()

func spend_attribute_points(count: int):
    free_attribute_points = max(0, free_attribute_points - count)

func calculate_exp_for_next_level():
    experience_for_next_level = 100.0 * pow(1.5, level - 1)

func get_exp_reward(monster_level: int) -> float:
    var base_exp = monster_level * 10
    var level_diff = monster_level - level
    
    if level_diff > 0:
        return base_exp * pow(1.5, level_diff)
    elif level_diff < 0:
        return max(0, base_exp * pow(0.5, abs(level_diff)))
    return base_exp
