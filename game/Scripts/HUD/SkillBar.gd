extends HUDElement

var skill_buttons: Array = []
var cooldown_masks: Array = []
var skill_manager: SkillManager = null

func _ready():
	super._ready()
	initialize_skill_bar()

func initialize_skill_bar():
	for i in range(5):
		var button: Button = get_node_or_null("Skill" + str(i + 1))
		var mask: TextureProgress = get_node_or_null("CooldownMask" + str(i + 1))
		
		if button:
			button.connect("pressed", self, "_on_skill_pressed", [i])
			skill_buttons.append(button)
		
		if mask:
			mask.visible = false
			cooldown_masks.append(mask)

func setup_listeners():
	if player and player.has_node("SkillManager"):
		skill_manager = player.get_node("SkillManager")

func update_hud():
	if not skill_manager:
		return
	
	for i in range(min(5, len(skill_buttons))):
		var skill_id: String = "skill_" + str(i + 1)
		var cooldown: float = skill_manager.get_skill_cooldown(skill_id)
		
		if cooldown > 0:
			if i < len(cooldown_masks):
				cooldown_masks[i].visible = true
				cooldown_masks[i].value = cooldown
				cooldown_masks[i].max_value = skill_manager.get_skill(skill_id).cooldown if skill_manager.get_skill(skill_id) else 1
		else:
			if i < len(cooldown_masks):
				cooldown_masks[i].visible = false

func _on_skill_pressed(index: int):
	if not skill_manager:
		return
	
	var skill_id: String = "skill_" + str(index + 1)
	skill_manager.cast_skill(skill_id, player.get_node("PlayerController").get_target())
