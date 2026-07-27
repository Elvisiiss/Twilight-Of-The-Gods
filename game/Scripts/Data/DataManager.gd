extends Node

var character_stats_data: Dictionary = {}
var skill_data: Dictionary = {}
var equipment_data: Dictionary = {}
var monster_data: Dictionary = {}
var quest_data: Dictionary = {}
var class_data: Dictionary = {}
var talent_data: Dictionary = {}

func _ready():
	load_all_data()

func load_all_data():
	load_json_data("character_stats", character_stats_data)
	load_json_data("skills", skill_data)
	load_json_data("equipment", equipment_data)
	load_json_data("monsters", monster_data)
	load_json_data("quests", quest_data)
	load_json_data("classes", class_data)
	load_json_data("talents", talent_data)

func load_json_data(file_name: String, target_dict: Dictionary):
	var path: String = "res://Data/%s.json" % file_name
	var file: File = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var content: String = file.get_as_text()
		file.close()
		var data: Dictionary = JSON.new().parse(content).result
		target_dict.merge(data)

func get_character_stats(id: String) -> Dictionary:
	return character_stats_data.get(id, {})

func get_skill(id: String) -> Dictionary:
	return skill_data.get(id, {})

func get_equipment(id: String) -> Dictionary:
	return equipment_data.get(id, {})

func get_monster(id: String) -> Dictionary:
	return monster_data.get(id, {})

func get_quest(id: String) -> Dictionary:
	return quest_data.get(id, {})

func get_class(id: String) -> Dictionary:
	return class_data.get(id, {})

func get_talent(id: String) -> Dictionary:
	return talent_data.get(id, {})
