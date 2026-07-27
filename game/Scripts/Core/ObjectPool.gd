extends Node

var pools: Dictionary = {}
var pre_warm_config: Dictionary = {}

func _ready():
	pre_warm_pools()

func pre_warm_pools():
	for pool_name in pre_warm_config:
		var config: Dictionary = pre_warm_config[pool_name]
		create_pool(pool_name, config["scene"], config["count"])

func create_pool(pool_name: String, scene: PackedScene, initial_count: int = 10):
	if pool_name not in pools:
		pools[pool_name] = {
			"scene": scene,
			"objects": [],
			"active": []
		}
	
	for i in range(initial_count):
		var obj: Node = scene.instance()
		obj.visible = false
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		obj.physics_process_mode = Node.PROCESS_MODE_DISABLED
		add_child(obj)
		pools[pool_name]["objects"].append(obj)

func get_object(pool_name: String) -> Node:
	if pool_name not in pools:
		return null
	
	var pool: Dictionary = pools[pool_name]
	if pool["objects"].empty():
		var obj: Node = pool["scene"].instance()
		add_child(obj)
	else:
		var obj: Node = pool["objects"].pop_front()
	
	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.physics_process_mode = Node.PROCESS_MODE_INHERIT
	pool["active"].append(obj)
	return obj

func return_object(pool_name: String, obj: Node):
	if pool_name not in pools:
		return
	
	var pool: Dictionary = pools[pool_name]
	if obj in pool["active"]:
		pool["active"].erase(obj)
		obj.visible = false
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		obj.physics_process_mode = Node.PROCESS_MODE_DISABLED
		obj.global_position = Vector2.ZERO
		pool["objects"].append(obj)

func return_all(pool_name: String):
	if pool_name not in pools:
		return
	
	var pool: Dictionary = pools[pool_name]
	while not pool["active"].empty():
		return_object(pool_name, pool["active"][0])

func set_pre_warm(pool_name: String, scene: PackedScene, count: int):
	pre_warm_config[pool_name] = {
		"scene": scene,
		"count": count
	}