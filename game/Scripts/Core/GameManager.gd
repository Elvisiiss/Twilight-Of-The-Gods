extends Node

enum GameState {
	BOOT,
	LOGIN,
	CHARACTER_SELECT,
	LOADING,
	PLAYING,
	PAUSED,
	DEAD,
	RESPAWN
}

var current_state: GameState = GameState.BOOT
var player: Node2D = null
var is_paused: bool = false

func _ready():
	change_state(GameState.BOOT)

func _process(delta: float):
	if current_state == GameState.PLAYING and not is_paused:
		_process_playing(delta)

func _process_playing(delta: float):
	pass

func change_state(new_state: GameState):
	current_state = new_state
	match new_state:
		GameState.BOOT:
			_on_boot()
		GameState.LOGIN:
			_on_login()
		GameState.CHARACTER_SELECT:
			_on_character_select()
		GameState.LOADING:
			_on_loading()
		GameState.PLAYING:
			_on_playing()
		GameState.PAUSED:
			_on_paused()
		GameState.DEAD:
			_on_dead()
		GameState.RESPAWN:
			_on_respawn()

func _on_boot():
	EventBus.on_death.connect(_on_player_death)
	EventBus.on_revive.connect(_on_player_revive)
	change_state(GameState.LOGIN)

func _on_login():
	print("登录界面")
	change_state(GameState.CHARACTER_SELECT)

func _on_character_select():
	print("角色选择界面")
	change_state(GameState.PLAYING)

func _on_loading():
	print("加载中...")

func _on_playing():
	print("开始游戏")

func _on_paused():
	is_paused = true
	print("游戏暂停")

func _on_dead():
	print("玩家死亡")

func _on_respawn():
	print("玩家复活")
	change_state(GameState.PLAYING)

func toggle_pause():
	if current_state == GameState.PLAYING:
		is_paused = not is_paused
		if is_paused:
			change_state(GameState.PAUSED)
		else:
			change_state(GameState.PLAYING)

func _on_player_death(character: Node, killer: Node):
	if character == player:
		change_state(GameState.DEAD)

func _on_player_revive(character: Node):
	if character == player:
		change_state(GameState.RESPAWN)