extends Node

var quests: Dictionary = {}
var active_quests: Array = []
var completed_quests: Array = []

func _ready():
	load_quests()

func load_quests():
	quests = {
		"main_1": QuestData.from_dict({
			"id": "main_1",
			"name": "踏上旅途",
			"description": "去找村庄长老交谈，开始你的冒险",
			"quest_type": QuestData.QuestType.MAIN,
			"required_level": 1,
			"objectives": [
				{"type": QuestData.ObjectiveType.TALK, "target": "village_elder", "amount": 1, "current": 0}
			],
			"rewards": {"experience": 100, "gold": 50},
			"start_npc": "village_elder",
			"end_npc": "village_elder",
			"priority": 10
		}),
		"main_2": QuestData.from_dict({
			"id": "main_2",
			"name": "初次战斗",
			"description": "前往训练区，击败5个训练假人",
			"quest_type": QuestData.QuestType.MAIN,
			"required_level": 2,
			"required_quests": ["main_1"],
			"objectives": [
				{"type": QuestData.ObjectiveType.KILL, "target": "training_dummy", "amount": 5, "current": 0}
			],
			"rewards": {"experience": 200, "gold": 100},
			"start_npc": "trainer",
			"end_npc": "trainer",
			"priority": 9
		}),
		"main_3": QuestData.from_dict({
			"id": "main_3",
			"name": "森林的威胁",
			"description": "前往森林边缘，消灭10只狼",
			"quest_type": QuestData.QuestType.MAIN,
			"required_level": 5,
			"required_quests": ["main_2"],
			"objectives": [
				{"type": QuestData.ObjectiveType.KILL, "target": "wolf", "amount": 10, "current": 0}
			],
			"rewards": {"experience": 500, "gold": 200},
			"start_npc": "village_elder",
			"end_npc": "village_elder",
			"priority": 8
		}),
		"main_4": QuestData.from_dict({
			"id": "main_4",
			"name": "哥布林的侵扰",
			"description": "前往黑暗森林，消灭哥布林营地的哥布林",
			"quest_type": QuestData.QuestType.MAIN,
			"required_level": 10,
			"required_quests": ["main_3"],
			"objectives": [
				{"type": QuestData.ObjectiveType.KILL, "target": "goblin", "amount": 15, "current": 0},
				{"type": QuestData.ObjectiveType.KILL, "target": "goblin_leader", "amount": 1, "current": 0}
			],
			"rewards": {"experience": 1000, "gold": 500},
			"start_npc": "forest_ranger",
			"end_npc": "forest_ranger",
			"priority": 7
		}),
		"side_1": QuestData.from_dict({
			"id": "side_1",
			"name": "收集草药",
			"description": "帮药剂师收集10株草药",
			"quest_type": QuestData.QuestType.SIDE,
			"required_level": 3,
			"objectives": [
				{"type": QuestData.ObjectiveType.COLLECT, "target": "herb", "amount": 10, "current": 0}
			],
			"rewards": {"experience": 150, "gold": 80},
			"start_npc": "healer",
			"end_npc": "healer",
			"priority": 5
		}),
		"side_2": QuestData.from_dict({
			"id": "side_2",
			"name": "武器修理",
			"description": "帮铁匠收集5个铁矿",
			"quest_type": QuestData.QuestType.SIDE,
			"required_level": 4,
			"objectives": [
				{"type": QuestData.ObjectiveType.COLLECT, "target": "iron_ore", "amount": 5, "current": 0}
			],
			"rewards": {"experience": 180, "gold": 100},
			"start_npc": "blacksmith",
			"end_npc": "blacksmith",
			"priority": 5
		})
	}

func accept_quest(quest_id: String) -> bool:
	if quest_id not in quests:
		return false
	
	var quest: QuestData = quests[quest_id]
	
	if quest.status != QuestData.QuestStatus.AVAILABLE:
		return false
	
	if quest.required_level > get_player_level():
		return false
	
	for required_quest in quest.required_quests:
		if required_quest not in completed_quests:
			return false
	
	quest.status = QuestData.QuestStatus.IN_PROGRESS
	active_quests.append(quest_id)
	
	EventBus.emit_quest_accept(quest_id)
	return true

func update_objective(quest_id: String, objective_type: int, target: String, amount: int = 1):
	if quest_id not in active_quests:
		return
	
	var quest: QuestData = quests[quest_id]
	
	for objective in quest.objectives:
		if objective["type"] == objective_type and objective["target"] == target:
			objective["current"] += amount
			
			if objective["current"] >= objective["amount"]:
				objective["current"] = objective["amount"]
			
			check_quest_completion(quest_id)
			return

func check_quest_completion(quest_id: String):
	if quest_id not in quests:
		return
	
	var quest: QuestData = quests[quest_id]
	var all_completed: bool = true
	
	for objective in quest.objectives:
		if objective["current"] < objective["amount"]:
			all_completed = false
			break
	
	if all_completed:
		quest.status = QuestData.QuestStatus.COMPLETED
		EventBus.emit_quest_complete(quest_id)

func complete_quest(quest_id: String) -> bool:
	if quest_id not in quests:
		return false
	
	var quest: QuestData = quests[quest_id]
	
	if quest.status != QuestData.QuestStatus.COMPLETED:
		return false
	
	grant_rewards(quest)
	
	quest.status = QuestData.QuestStatus.REWARDED
	active_quests.erase(quest_id)
	completed_quests.append(quest_id)
	
	if quest.is_repeatable:
		get_tree().create_timer(quest.repeat_cooldown).connect("timeout", self, "_on_quest_reset", [quest_id])
	
	EventBus.emit_quest_reward(quest_id)
	return true

func grant_rewards(quest: QuestData):
	var player: Node = get_player()
	if not player:
		return
	
	if player.has_node("LevelSystem") and "experience" in quest.rewards:
		var level_system: LevelSystem = player.get_node("LevelSystem")
		level_system.add_experience(quest.rewards["experience"])
	
	if player.has_node("CurrencySystem") and "gold" in quest.rewards:
		var currency_system: CurrencySystem = player.get_node("CurrencySystem")
		currency_system.add_gold(quest.rewards["gold"])
	
	if player.has_node("InventorySystem") and "items" in quest.rewards:
		var inventory: InventorySystem = player.get_node("InventorySystem")
		for item_id in quest.rewards["items"]:
			inventory.add_item({"id": item_id, "name": item_id, "type": "material"}, 1)

func _on_quest_reset(quest_id: String):
	if quest_id in quests:
		var quest: QuestData = quests[quest_id]
		quest.status = QuestData.QuestStatus.AVAILABLE
		for objective in quest.objectives:
			objective["current"] = 0

func get_available_quests() -> Array:
	var available: Array = []
	for quest_id in quests:
		var quest: QuestData = quests[quest_id]
		
		if quest.status != QuestData.QuestStatus.AVAILABLE:
			continue
		
		if quest.required_level > get_player_level():
			continue
		
		var has_required: bool = true
		for required_quest in quest.required_quests:
			if required_quest not in completed_quests:
				has_required = false
				break
		
		if has_required:
			available.append(quest)
	
	return available

func get_active_quests() -> Array:
	var result: Array = []
	for quest_id in active_quests:
		if quest_id in quests:
			result.append(quests[quest_id])
	return result

func get_quest(quest_id: String) -> QuestData:
	return quests.get(quest_id, null)

func get_player_level() -> int:
	var player: Node = get_player()
	if player and player.has_node("LevelSystem"):
		return player.get_node("LevelSystem").current_level
	return 1

func get_player() -> Node:
	var players: Array = get_tree().get_nodes_in_group("players")
	if not players.empty():
		return players[0]
	return null
