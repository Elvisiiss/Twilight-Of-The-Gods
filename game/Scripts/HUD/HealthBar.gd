extends HUDElement

var hp_bar: ProgressBar = null
var mp_bar: ProgressBar = null
var hp_label: Label = null
var mp_label: Label = null

func _ready():
	super._ready()
	hp_bar = $HPBar
	mp_bar = $MPBar
	hp_label = $HPLabel
	mp_label = $MPLabel

func setup_listeners():
	if player and player.has_node("CharacterStats"):
		EventBus.connect("stat_change", self, "_on_stat_change")

func update_hud():
	if not player or not player.has_node("CharacterStats"):
		return
	
	var stats: CharacterStats = player.get_node("CharacterStats")
	var hp: float = stats.get_stat("hp")
	var mp: float = stats.get_stat("mp")
	
	hp_bar.value = hp
	hp_bar.max_value = hp
	
	mp_bar.value = mp
	mp_bar.max_value = mp
	
	hp_label.text = str(int(hp)) + "/" + str(int(hp))
	mp_label.text = str(int(mp)) + "/" + str(int(mp))

func _on_stat_change(character: Node, stat_name: String, old_value: float, new_value: float):
	if character == player:
		update_hud()
