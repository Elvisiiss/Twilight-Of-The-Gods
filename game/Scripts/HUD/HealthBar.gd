extends ProgressBar

var target: Node = null
var max_hp: float = 100.0
var current_hp: float = 100.0

func _ready():
    max_value = 100
    value = 100

func set_target(p_target: Node):
    target = p_target

func update_health():
    if not target or not target.has_method("get_stat"):
        return
    
    current_hp = target.get_stat("hp")
    max_hp = target.get_stat("hp") * 2
    
    if max_hp > 0:
        value = (current_hp / max_hp) * 100
    else:
        value = 0

func _process(delta: float):
    update_health()
