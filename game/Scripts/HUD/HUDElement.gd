extends Control

var player: Node = null

func _ready():
	connect_to_player()

func connect_to_player():
	var players: Array = get_tree().get_nodes_in_group("players")
	if not players.empty():
		player = players[0]
		setup_listeners()

func setup_listeners():
	pass

func update_hud():
	pass

func _process(delta: float):
	update_hud()
