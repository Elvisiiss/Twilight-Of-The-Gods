extends Node

var hate_table: Dictionary = {}
var max_hate: float = 100.0
var decay_rate: float = 0.1

func _ready():
	pass

func add_hate(source: Node, amount: float):
	var key: String = str(source.get_path())
	if key not in hate_table:
		hate_table[key] = {"source": source, "hate": 0.0}
	
	hate_table[key]["hate"] = min(max_hate, hate_table[key]["hate"] + amount)

func remove_hate(source: Node, amount: float):
	var key: String = str(source.get_path())
	if key in hate_table:
		hate_table[key]["hate"] = max(0.0, hate_table[key]["hate"] - amount)
		if hate_table[key]["hate"] <= 0:
			hate_table.erase(key)

func get_top_target() -> Node:
	var top_target: Node = null
	var top_hate: float = 0.0
	
	for key in hate_table:
		if hate_table[key]["hate"] > top_hate:
			top_hate = hate_table[key]["hate"]
			top_target = hate_table[key]["source"]
	
	return top_target

func get_hate_amount(source: Node) -> float:
	var key: String = str(source.get_path())
	return hate_table.get(key, {}).get("hate", 0.0)

func update_hate(delta: float):
	var to_remove: Array = []
	
	for key in hate_table:
		hate_table[key]["hate"] -= decay_rate * delta
		if hate_table[key]["hate"] <= 0:
			to_remove.append(key)
	
	for key in to_remove:
		hate_table.erase(key)

func clear_hate():
	hate_table.clear()

func is_hating(source: Node) -> bool:
	var key: String = str(source.get_path())
	return key in hate_table

func get_all_targets() -> Array:
	var targets: Array = []
	for key in hate_table:
		targets.append(hate_table[key]["source"])
	return targets

func _process(delta: float):
	update_hate(delta)
