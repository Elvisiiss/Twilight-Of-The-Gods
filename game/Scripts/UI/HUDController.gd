extends CanvasLayer

var player: Node = null
var hp_bar: ProgressBar = null
var mp_bar: ProgressBar = null
var level_label: Label = null
var exp_bar: ProgressBar = null

func _ready():
    hp_bar = $HUD/HPBar
    mp_bar = $HUD/MPBar
    level_label = $HUD/LevelLabel
    exp_bar = $HUD/ExpBar
    
    _find_player()

func _find_player():
    for node in get_tree().get_nodes_in_group("player"):
        player = node
        break

func _process(delta: float):
    if not player or not is_instance_valid(player):
        _find_player()
        return
    
    _update_hp()
    _update_mp()
    _update_level()
    _update_exp()

func _update_hp():
    if player.has_method("get_stat"):
        var current_hp = player.get_stat("hp")
        var max_hp = player.get_stat("max_hp")
        
        if hp_bar:
            hp_bar.max_value = max_hp
            hp_bar.value = current_hp

func _update_mp():
    if player.has_method("get_stat"):
        var current_mp = player.get_stat("mp")
        var max_mp = player.get_stat("max_mp")
        
        if mp_bar:
            mp_bar.max_value = max_mp
            mp_bar.value = current_mp

func _update_level():
    var level_system = null
    if player.has_method("get_child"):
        for child in player.get_children():
            if child is LevelSystem:
                level_system = child
                break
    
    if level_system:
        var level = level_system.get_level()
        if level_label:
            level_label.text = "Lv." + str(level)

func _update_exp():
    var level_system = null
    if player.has_method("get_child"):
        for child in player.get_children():
            if child is LevelSystem:
                level_system = child
                break
    
    if level_system:
        var exp = level_system.get_experience()
        var exp_for_next = level_system.get_experience_for_next_level()
        
        if exp_bar:
            exp_bar.max_value = exp_for_next
            exp_bar.value = exp