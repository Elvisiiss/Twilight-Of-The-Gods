class QuestData:
	enum QuestType {
		MAIN,
		SIDE,
		DUNGEON,
		Daily,
		Guild,
		PK
	}
	
	enum QuestStatus {
		AVAILABLE,
		ACCEPTED,
		IN_PROGRESS,
		COMPLETED,
		REWARDED
	}
	
	enum ObjectiveType {
		KILL,
		COLLECT,
		DELIVER,
		REACH,
		TALK,
		USE,
		ESCORT,
		SURVIVE
	}
	
	var id: String
	var name: String
	var description: String
	var quest_type: QuestType
	var status: QuestStatus
	var required_level: int
	var required_quests: Array
	var objectives: Array
	var rewards: Dictionary
	var start_npc: String
	var end_npc: String
	var is_repeatable: bool
	var repeat_cooldown: float
	var priority: int
	
	func _init():
		self.id = ""
		self.name = ""
		self.description = ""
		self.quest_type = QuestType.MAIN
		self.status = QuestStatus.AVAILABLE
		self.required_level = 1
		self.required_quests = []
		self.objectives = []
		self.rewards = {}
		self.start_npc = ""
		self.end_npc = ""
		self.is_repeatable = false
		self.repeat_cooldown = 0.0
		self.priority = 1
	
	static func from_dict(data: Dictionary) -> QuestData:
		var quest: QuestData = QuestData.new()
		quest.id = data.get("id", "")
		quest.name = data.get("name", "")
		quest.description = data.get("description", "")
		quest.quest_type = data.get("quest_type", QuestType.MAIN)
		quest.status = data.get("status", QuestStatus.AVAILABLE)
		quest.required_level = data.get("required_level", 1)
		quest.required_quests = data.get("required_quests", [])
		quest.objectives = data.get("objectives", [])
		quest.rewards = data.get("rewards", {})
		quest.start_npc = data.get("start_npc", "")
		quest.end_npc = data.get("end_npc", "")
		quest.is_repeatable = data.get("is_repeatable", false)
		quest.repeat_cooldown = data.get("repeat_cooldown", 0.0)
		quest.priority = data.get("priority", 1)
		return quest
