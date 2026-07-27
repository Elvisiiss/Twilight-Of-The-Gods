extends Control

var player: Node = null
var character_stats: CharacterStats = null
var level_system: LevelSystem = null
var class_system: ClassSystem = null
var talent_system: TalentSystem = null

var stat_labels: Dictionary = {}
var is_visible: bool = false

func _ready():
	connect_to_player()
	initialize_stat_labels()

func connect_to_player():
	var players: Array = get_tree().get_nodes_in_group("players")
	if not players.empty():
		player = players[0]
		if player.has_node("CharacterStats"):
			character_stats = player.get_node("CharacterStats")
		if player.has_node("LevelSystem"):
			level_system = player.get_node("LevelSystem")
		if player.has_node("ClassSystem"):
			class_system = player.get_node("ClassSystem")
		if player.has_node("TalentSystem"):
			talent_system = player.get_node("TalentSystem")

func initialize_stat_labels():
	var stats: Array = ["hp", "mp", "attack", "magic_power", "armor", "magic_resist", "attack_speed", "move_speed", "crit_rate", "crit_damage"]
	
	for stat in stats:
		var label: Label = get_node_or_null("Stat" + stat.capitalize())
		if label:
			stat_labels[stat] = label

func show_panel():
	is_visible = true
	visible = true
	update_panel()

func hide_panel():
	is_visible = false
	visible = false

func toggle_panel():
	if is_visible:
		hide_panel()
	else:
		show_panel()

func update_panel():
	if not character_stats:
		return
	
	for stat in stat_labels:
		var value: float = character_stats.get_stat(stat)
		var label: Label = stat_labels[stat]
		
		if label:
			label.text = str(int(value))
	
	if level_system:
		var level_label: Label = get_node_or_null("LevelLabel")
		if level_label:
			level_label.text = "等级: " + str(level_system.current_level)
		
		var exp_label: Label = get_node_or_null("ExpLabel")
		if exp_label:
			exp_label.text = "经验: " + str(level_system.current_experience) + "/" + str(level_system.calculate_required_experience(level_system.current_level))
		
		var points_label: Label = get_node_or_null("PointsLabel")
		if points_label:
			points_label.text = "属性点: " + str(level_system.free_attribute_points)
	
	if class_system:
		var class_label: Label = get_node_or_null("ClassLabel")
		if class_label:
			var class_data: ClassData = class_system.get_current_class()
			class_label.text = "职业: " + (class_data.name if class_data else "未选择")
	
	if talent_system:
		var talent_label: Label = get_node_or_null("TalentLabel")
		if talent_label:
			var active_talents: Array = talent_system.get_active_talents()
			talent_label.text = "已装备天赋: " + str(len(active_talents))
