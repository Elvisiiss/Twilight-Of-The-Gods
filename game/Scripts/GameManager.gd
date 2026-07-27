extends Node2D

enum GameState { BOOT, LOGIN, CHARACTER_SELECT, LOADING, PLAYING, PAUSED, DEAD, RESPAWN }

var current_state: GameState = GameState.BOOT

onready var player = $Player
onready var camera = $Camera2D
onready var event_bus = null
onready var data_manager = null
onready var hud = null

func _ready():
    _on_boot()

func _process(delta: float):
    match current_state:
        GameState.PLAYING: _on_playing(delta)
        GameState.DEAD: _on_dead(delta)

func change_state(new_state: GameState):
    current_state = new_state
    match new_state:
        GameState.BOOT: _on_boot()
        GameState.LOGIN: _on_login()
        GameState.CHARACTER_SELECT: _on_character_select()
        GameState.LOADING: _on_loading()
        GameState.PLAYING: _on_playing_enter()
        GameState.PAUSED: _on_paused()
        GameState.DEAD: _on_dead_enter()
        GameState.RESPAWN: _on_respawn()

func _on_boot():
    data_manager = DataManager.new()
    data_manager.init()
    
    event_bus = EventBus.new()
    add_child(event_bus)
    
    yield(get_tree(), "idle_frame")
    change_state(GameState.LOGIN)

func _on_login():
    change_state(GameState.CHARACTER_SELECT)

func _on_character_select():
    change_state(GameState.PLAYING)

func _on_loading():
    pass

func _on_playing_enter():
    if player:
        player.init_player()

func _on_playing(delta: float):
    if camera and player:
        camera.position = player.global_position

func _on_paused():
    pass

func _on_dead_enter():
    pass

func _on_dead(delta: float):
    pass

func _on_respawn():
    if player:
        player.respawn()
    change_state(GameState.PLAYING)

func get_event_bus() -> EventBus:
    return event_bus

func get_data_manager() -> DataManager:
    return data_manager

func get_player() -> Node:
    return player
