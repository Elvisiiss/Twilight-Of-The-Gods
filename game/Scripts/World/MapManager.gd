extends Node

var current_map: String = ""
var maps: Dictionary = {}
var area_data: Dictionary = {}
var player_spawn_point: Vector2 = Vector2.ZERO
var map_transitions: Dictionary = {}

func _ready():
	load_maps()

func load_maps():
	maps = {
		"start_village": {
			"name": "新手村",
			"description": "冒险的起点",
			"width": 2000,
			"height": 1500,
			"background": "res://Assets/Maps/start_village.png",
			"music": "res://Assets/Audio/Music/start_village.mp3",
			"spawn_point": Vector2(1000, 750),
			"areas": ["village_center", "training_area", "forest_edge"]
		},
		"dark_forest": {
			"name": "黑暗森林",
			"description": "充满危险的森林",
			"width": 3000,
			"height": 2500,
			"background": "res://Assets/Maps/dark_forest.png",
			"music": "res://Assets/Audio/Music/dark_forest.mp3",
			"spawn_point": Vector2(1500, 1250),
			"areas": ["forest_path", "goblin_camp", "ancient_tree"]
		},
		"dragon_cave": {
			"name": "龙穴",
			"description": "传说中龙居住的洞穴",
			"width": 4000,
			"height": 3000,
			"background": "res://Assets/Maps/dragon_cave.png",
			"music": "res://Assets/Audio/Music/dragon_cave.mp3",
			"spawn_point": Vector2(2000, 1500),
			"areas": ["cave_entrance", "treasure_room", "dragon_nest"]
		},
		"god_realm": {
			"name": "神界",
			"description": "诸神居住的领域",
			"width": 5000,
			"height": 4000,
			"background": "res://Assets/Maps/god_realm.png",
			"music": "res://Assets/Audio/Music/god_realm.mp3",
			"spawn_point": Vector2(2500, 2000),
			"areas": ["divine_plaza", "world_tree", "throne_room"]
		}
	}

func load_area_data():
	area_data = {
		"village_center": {
			"name": "村庄中心",
			"description": "村庄的核心区域",
			"bounds": Rect2(800, 600, 400, 300),
			"monsters": [],
			"npcs": ["village_elder", "blacksmith", "healer"]
		},
		"training_area": {
			"name": "训练区",
			"description": "新手训练的地方",
			"bounds": Rect2(500, 1000, 300, 300),
			"monsters": ["training_dummy"],
			"npcs": ["trainer"]
		},
		"forest_edge": {
			"name": "森林边缘",
			"description": "森林的入口",
			"bounds": Rect2(1600, 600, 300, 400),
			"monsters": ["wolf", "goblin"],
			"npcs": []
		},
		"forest_path": {
			"name": "森林小径",
			"description": "穿过森林的小路",
			"bounds": Rect2(1000, 1000, 500, 400),
			"monsters": ["wolf", "goblin", "skeleton"],
			"npcs": ["forest_ranger"]
		},
		"goblin_camp": {
			"name": "哥布林营地",
			"description": "哥布林的据点",
			"bounds": Rect2(2000, 1500, 400, 400),
			"monsters": ["goblin", "goblin_leader", "goblin_shaman"],
			"npcs": []
		},
		"dragon_nest": {
			"name": "龙巢",
			"description": "巨龙的巢穴",
			"bounds": Rect2(3000, 2000, 500, 500),
			"monsters": ["dragon"],
			"npcs": []
		}
	}

func load_map(map_id: String) -> bool:
	if map_id not in maps:
		return false
	
	current_map = map_id
	var map_data: Dictionary = maps[map_id]
	player_spawn_point = map_data["spawn_point"]
	
	EventBus.emit_map_change(map_id)
	return true

func get_current_map() -> Dictionary:
	return maps.get(current_map, {})

func get_map_area(world_position: Vector2) -> String:
	if not current_map:
		return ""
	
	var map_data: Dictionary = maps[current_map]
	for area_id in map_data["areas"]:
		if area_id in area_data:
			var area: Dictionary = area_data[area_id]
			if area["bounds"].has_point(world_position):
				return area_id
	
	return ""

func get_area_info(area_id: String) -> Dictionary:
	return area_data.get(area_id, {})

func set_map_transition(from_map: String, to_map: String, position: Vector2):
	if from_map not in map_transitions:
		map_transitions[from_map] = []
	
	map_transitions[from_map].append({
		"to_map": to_map,
		"position": position,
		"radius": 50
	})

func check_transition(player_position: Vector2) -> String:
	if current_map not in map_transitions:
		return ""
	
	for transition in map_transitions[current_map]:
		var distance: float = player_position.distance_to(transition["position"])
		if distance <= transition["radius"]:
			return transition["to_map"]
	
	return ""

func get_spawn_point() -> Vector2:
	return player_spawn_point

func is_safe_area(position: Vector2) -> bool:
	var area_id: String = get_map_area(position)
	var area: Dictionary = get_area_info(area_id)
	return area.get("is_safe", false)
