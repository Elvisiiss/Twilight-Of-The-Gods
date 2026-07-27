extends Node

func _ready():
	pass

func generate_loot(monster_data: MonsterData) -> Array:
	var loot: Array = []
	
	if monster_data.gold_reward > 0:
		loot.append({
			"id": "gold",
			"name": "金币",
			"type": "currency",
			"amount": monster_data.gold_reward,
			"stackable": true
		})
	
	if monster_data.exp_reward > 0:
		loot.append({
			"id": "experience",
			"name": "经验",
			"type": "experience",
			"amount": monster_data.exp_reward,
			"stackable": false
		})
	
	for item_id in monster_data.loot_table:
		var item_data: Dictionary = monster_data.loot_table[item_id]
		var chance: float = item_data.get("chance", 0.0)
		
		if randf() < chance:
			var count: int = item_data.get("count", 1)
			if item_data.get("random_count", false):
				count = rand_range(item_data.get("min_count", 1), item_data.get("max_count", 5))
			
			loot.append({
				"id": item_id,
				"name": item_data.get("name", item_id),
				"type": item_data.get("type", "material"),
				"amount": count,
				"stackable": true
			})
	
	if monster_data.is_boss:
		roll_boss_loot(monster_data, loot)
	
	return loot

func roll_boss_loot(monster_data: MonsterData, loot: Array):
	var equipment_generator: EquipmentGenerator = EquipmentGenerator.new()
	var equipment: EquipmentData = equipment_generator.generate_equipment(monster_data.level, RaritySystem.Rarity.STARLIGHT)
	
	if equipment:
		loot.append({
			"id": equipment.id,
			"name": equipment.name,
			"type": "equipment",
			"data": equipment,
			"amount": 1,
			"stackable": false
		})

func distribute_loot(loot: Array, players: Array):
	if players.empty():
		return
	
	var player_index: int = 0
	for item in loot:
		var player: Node = players[player_index % len(players)]
		
		if player.has_node("InventorySystem"):
			var inventory: InventorySystem = player.get_node("InventorySystem")
			if item["type"] == "equipment":
				inventory.add_item(item["data"])
			else:
				inventory.add_item({"id": item["id"], "name": item["name"], "type": item["type"]}, item["amount"])
		
		if player.has_node("LevelSystem") and item["type"] == "experience":
			var level_system: LevelSystem = player.get_node("LevelSystem")
			level_system.add_experience(item["amount"])
		
		if player.has_node("CurrencySystem") and item["type"] == "currency":
			var currency_system: CurrencySystem = player.get_node("CurrencySystem")
			currency_system.add_gold(item["amount"])
		
		player_index += 1

func drop_loot_on_ground(loot: Array, position: Vector2):
	for item in loot:
		var loot_scene: PackedScene = load("res://Scenes/Loot/LootItem.tscn")
		if loot_scene:
			var loot_item: Node = loot_scene.instance()
			loot_item.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
			loot_item.set_item_data(item)
			get_tree().root.add_child(loot_item)
