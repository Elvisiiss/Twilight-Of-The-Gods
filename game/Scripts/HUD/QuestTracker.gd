extends HUDElement

var quest_list: VBoxContainer = null
var quest_manager: QuestManager = null

func _ready():
	super._ready()
	quest_list = $QuestList
	
	var quest_manager_node: Node = get_node_or_null("/root/QuestManager")
	if quest_manager_node:
		quest_manager = quest_manager_node
	
	if quest_manager:
		EventBus.connect("quest_accept", self, "_on_quest_update")
		EventBus.connect("quest_complete", self, "_on_quest_update")
		EventBus.connect("quest_reward", self, "_on_quest_update")

func update_hud():
	if not quest_manager:
		return
	
	update_quest_list()

func update_quest_list():
	var active_quests: Array = quest_manager.get_active_quests()
	
	for child in quest_list.get_children():
		child.queue_free()
	
	for quest in active_quests:
		var quest_item: VBoxContainer = VBoxContainer.new()
		
		var quest_name: Label = Label.new()
		quest_name.text = "[b]" + quest.name + "[/b]"
		quest_name.add_font_override("font", get_font("font"))
		quest_name.add_style_override("font_color", Color(1, 1, 0))
		quest_item.add_child(quest_name)
		
		for objective in quest.objectives:
			var objective_label: Label = Label.new()
			var progress: String = str(objective["current"]) + "/" + str(objective["amount"])
			var objective_text: String = get_objective_text(objective)
			objective_label.text = "- " + objective_text + " (" + progress + ")"
			objective_label.add_style_override("font_color", Color(0.8, 0.8, 0.8))
			quest_item.add_child(objective_label)
		
		quest_list.add_child(quest_item)

func get_objective_text(objective: Dictionary) -> String:
	match objective["type"]:
		QuestData.ObjectiveType.KILL:
			return "击杀 " + objective["target"]
		QuestData.ObjectiveType.COLLECT:
			return "收集 " + objective["target"]
		QuestData.ObjectiveType.DELIVER:
			return "交付物品"
		QuestData.ObjectiveType.REACH:
			return "到达指定地点"
		QuestData.ObjectiveType.TALK:
			return "与 " + objective["target"] + " 交谈"
		_:
			return "完成任务"

func _on_quest_update():
	update_quest_list()
