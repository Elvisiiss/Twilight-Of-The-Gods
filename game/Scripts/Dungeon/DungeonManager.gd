extends Node

var dungeons: Dictionary = {}
var active_instances: Dictionary = {}

func _ready():
	load_dungeons()

func load_dungeons():
	dungeons = {
		"goblin_dungeon": {
			"id": "goblin_dungeon",
			"name": "哥布林巢穴",
			"description": "充满哥布林的地下巢穴",
			"required_level": 10,
			"max_players": 5,
			"difficulty": "normal",
			"duration": 300,
			"rewards": {"experience": 2000, "gold": 1000},
			"boss": "goblin_king",
			"monsters": ["goblin", "goblin_archer", "goblin_shaman"],
			"waves": [
				{"monsters": {"goblin": 5}, "delay": 10},
				{"monsters": {"goblin": 8, "goblin_archer": 2}, "delay": 15},
				{"monsters": {"goblin_shaman": 3, "goblin": 5}, "delay": 20},
				{"monsters": {"goblin_king": 1}, "delay": 0}
			]
		},
		"skeleton_dungeon": {
			"id": "skeleton_dungeon",
			"name": "骷髅地牢",
			"description": "亡灵法师的领地",
			"required_level": 20,
			"max_players": 5,
			"difficulty": "hard",
			"duration": 400,
			"rewards": {"experience": 5000, "gold": 2500},
			"boss": "lich_king",
			"monsters": ["skeleton", "skeleton_archer", "ghost"],
			"waves": [
				{"monsters": {"skeleton": 10}, "delay": 10},
				{"monsters": {"skeleton": 5, "skeleton_archer": 5}, "delay": 15},
				{"monsters": {"ghost": 5, "skeleton": 5}, "delay": 20},
				{"monsters": {"lich_king": 1}, "delay": 0}
			]
		},
		"dragon_dungeon": {
			"id": "dragon_dungeon",
			"name": "龙穴深处",
			"description": "远古巨龙的领地",
			"required_level": 30,
			"max_players": 10,
			"difficulty": "epic",
			"duration": 600,
			"rewards": {"experience": 15000, "gold": 10000},
			"boss": "ancient_dragon",
			"monsters": ["dragon_whelp", "dragon_guardian"],
			"waves": [
				{"monsters": {"dragon_whelp": 8}, "delay": 15},
				{"monsters": {"dragon_whelp": 10, "dragon_guardian": 3}, "delay": 20},
				{"monsters": {"dragon_guardian": 5}, "delay": 25},
				{"monsters": {"ancient_dragon": 1}, "delay": 0}
			]
		}
	}

func create_instance(dungeon_id: String, players: Array) -> String:
	if dungeon_id not in dungeons:
		return ""
	
	var dungeon: Dictionary = dungeons[dungeon_id]
	
	if len(players) > dungeon["max_players"]:
		return ""
	
	for player in players:
		if player.has_node("LevelSystem"):
			var level: int = player.get_node("LevelSystem").current_level
			if level < dungeon["required_level"]:
				return ""
	
	var instance_id: String = dungeon_id + "_" + str(OS.get_ticks_msec())
	
	active_instances[instance_id] = {
		"dungeon_id": dungeon_id,
		"players": players,
		"current_wave": 0,
		"start_time": OS.get_ticks_msec(),
		"status": "active",
		"wave_timer": null
	}
	
	for player in players:
		teleport_player_to_dungeon(player, dungeon_id)
	
	EventBus.emit_dungeon_enter(instance_id)
	
	start_next_wave(instance_id)
	
	return instance_id

func start_next_wave(instance_id: String):
	if instance_id not in active_instances:
		return
	
	var instance: Dictionary = active_instances[instance_id]
	var dungeon: Dictionary = dungeons[instance["dungeon_id"]]
	
	if instance["current_wave"] >= len(dungeon["waves"]):
		complete_dungeon(instance_id)
		return
	
	var wave: Dictionary = dungeon["waves"][instance["current_wave"]]
	
	if wave["delay"] > 0:
		instance["wave_timer"] = get_tree().create_timer(wave["delay"])
		instance["wave_timer"].connect("timeout", self, "_on_wave_ready", [instance_id])
	else:
		spawn_wave(instance_id)

func _on_wave_ready(instance_id: String):
	spawn_wave(instance_id)

func spawn_wave(instance_id: String):
	if instance_id not in active_instances:
		return
	
	var instance: Dictionary = active_instances[instance_id]
	var dungeon: Dictionary = dungeons[instance["dungeon_id"]]
	var wave: Dictionary = dungeon["waves"][instance["current_wave"]]
	
	for monster_id in wave["monsters"]:
		var count: int = wave["monsters"][monster_id]
		for i in range(count):
			spawn_monster(monster_id, instance_id)
	
	instance["current_wave"] += 1
	
	EventBus.emit_dungeon_wave(instance_id, instance["current_wave"])

func spawn_monster(monster_id: String, instance_id: String):
	var monster_scene: PackedScene = load("res://Scenes/Monster/" + monster_id + ".tscn")
	if monster_scene:
		var monster: Node = monster_scene.instance()
		var instance: Dictionary = active_instances[instance_id]
		
		var dungeon: Dictionary = dungeons[instance["dungeon_id"]]
		var spawn_x: float = rand_range(500, 1500)
		var spawn_y: float = rand_range(500, 1500)
		monster.global_position = Vector2(spawn_x, spawn_y)
		
		get_tree().root.add_child(monster)
		
		if monster.has_node("MonsterAI"):
			monster.get_node("MonsterAI").target = instance["players"][0]

func complete_dungeon(instance_id: String):
	if instance_id not in active_instances:
		return
	
	var instance: Dictionary = active_instances[instance_id]
	var dungeon: Dictionary = dungeons[instance["dungeon_id"]]
	
	for player in instance["players"]:
		if player.has_node("LevelSystem"):
			var level_system: LevelSystem = player.get_node("LevelSystem")
			level_system.add_experience(dungeon["rewards"]["experience"])
		
		if player.has_node("CurrencySystem"):
			var currency_system: CurrencySystem = player.get_node("CurrencySystem")
			currency_system.add_gold(dungeon["rewards"]["gold"])
		
		teleport_player_out(player)
	
	instance["status"] = "completed"
	
	EventBus.emit_dungeon_complete(instance_id)
	
	get_tree().create_timer(5.0).connect("timeout", self, "_cleanup_instance", [instance_id])

func _cleanup_instance(instance_id: String):
	if instance_id in active_instances:
		active_instances.erase(instance_id)

func teleport_player_to_dungeon(player: Node, dungeon_id: String):
	var dungeon: Dictionary = dungeons[dungeon_id]
	player.global_position = Vector2(1000, 1000)

func teleport_player_out(player: Node):
	var map_manager: MapManager = get_node_or_null("/root/MapManager")
	if map_manager:
		player.global_position = map_manager.get_spawn_point()
