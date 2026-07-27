extends Panel

var character: Node = null
var stats_label: Label = null

func _ready():
    stats_label = Label.new()
    stats_label.position = Vector2(10, 10)
    stats_label.autowrap_mode = Label.AUTOWRAP_WORD
    add_child(stats_label)
    visible = false

func set_character(p_character: Node):
    character = p_character

func update_stats():
    if not character or not character.has_method("get_stat"):
        return
    
    var text = "属性面板:\n\n"
    text += "生命值: %.0f\n" % character.get_stat("hp")
    text += "法力值: %.0f\n" % character.get_stat("mp")
    text += "攻击力: %.0f\n" % character.get_stat("attack")
    text += "法术强度: %.0f\n" % character.get_stat("magic_power")
    text += "护甲: %.0f\n" % character.get_stat("armor")
    text += "魔抗: %.0f\n" % character.get_stat("magic_resist")
    text += "攻速: %.2f\n" % character.get_stat("attack_speed")
    text += "移速: %.2f\n" % character.get_stat("move_speed")
    text += "暴击率: %.1f%%\n" % (character.get_stat("crit_rate") * 100)
    text += "暴击伤害: %.0f%%\n" % (character.get_stat("crit_damage") * 100)
    
    stats_label.text = text

func toggle():
    visible = not visible
    if visible:
        update_stats()

func _process(delta: float):
    if visible:
        update_stats()
