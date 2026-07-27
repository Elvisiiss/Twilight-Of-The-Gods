extends Control

var skill_buttons: Array = []
var skill_manager: SkillManager = null

func _ready():
    skill_buttons = []

func set_skill_manager(manager: SkillManager):
    skill_manager = manager

func add_skill_button(slot: String, icon_path: String):
    var button = Button.new()
    button.text = slot
    button.set_icon(load(icon_path))
    add_child(button)
    skill_buttons.append({"slot": slot, "button": button})

func update_cooldowns(delta: float):
    if not skill_manager:
        return
    
    for skill_data in skill_buttons:
        var slot = skill_data["slot"]
        var button = skill_data["button"]
        var skill_id = skill_manager.get_skill_in_slot(slot)
        
        if skill_id:
            var cooldown = skill_manager.get_cooldown(skill_id)
            if cooldown > 0:
                button.disabled = true
                button.text = str(int(cooldown))
            else:
                button.disabled = false
                button.text = ""

func _process(delta: float):
    update_cooldowns(delta)
