extends Node

var input_map: Dictionary = {}
var key_bindings: Dictionary = {}
var is_input_enabled: bool = true

func _ready():
	load_default_bindings()

func load_default_bindings():
	key_bindings = {
		"move_up": ["w", "arrow_up"],
		"move_down": ["s", "arrow_down"],
		"move_left": ["a", "arrow_left"],
		"move_right": ["d", "arrow_right"],
		"attack": ["mouse_left"],
		"skill_1": ["1"],
		"skill_2": ["2"],
		"skill_3": ["3"],
		"skill_4": ["4"],
		"skill_5": ["5"],
		"skill_6": ["6"],
		"skill_7": ["7"],
		"skill_8": ["8"],
		"skill_9": ["9"],
		"skill_0": ["0"],
		"dodge": ["space"],
		"interact": ["f"],
		"inventory": ["b"],
		"map": ["m"],
		"pause": ["escape"],
		"character": ["c"],
		"skills": ["k"],
		"quests": ["l"]
	}

func is_action_pressed(action: String) -> bool:
	if not is_input_enabled:
		return false
	
	var keys: Array = key_bindings.get(action, [])
	for key in keys:
		if Input.is_key_pressed(Input.get_keycode_from_string(key)):
			return true
	return false

func is_action_just_pressed(action: String) -> bool:
	if not is_input_enabled:
		return false
	
	var keys: Array = key_bindings.get(action, [])
	for key in keys:
		if Input.is_action_just_pressed(key):
			return true
	return false

func get_movement_vector() -> Vector2:
	var vector: Vector2 = Vector2.ZERO
	if is_action_pressed("move_up"):
		vector.y -= 1
	if is_action_pressed("move_down"):
		vector.y += 1
	if is_action_pressed("move_left"):
		vector.x -= 1
	if is_action_pressed("move_right"):
		vector.x += 1
	return vector.normalized()

func set_input_enabled(enabled: bool):
	is_input_enabled = enabled

func save_bindings():
	var file: File = File.new()
	file.open("user://key_bindings.json", File.WRITE)
	file.store_string(JSON.new().print(key_bindings))
	file.close()

func load_bindings():
	var file: File = File.new()
	if file.file_exists("user://key_bindings.json"):
		file.open("user://key_bindings.json", File.READ)
		var content: String = file.get_as_text()
		file.close()
		var data: Dictionary = JSON.new().parse(content).result
		key_bindings.merge(data)

func _input(event: InputEvent):
	if not is_input_enabled:
		return
