extends Node

enum GameState { BOOT, LOGIN, CHARACTER_SELECT, LOADING, PLAYING, PAUSED, DEAD, RESPAWN }

var current_state: GameState = GameState.BOOT
var player: Node2D = null
var event_bus: EventBus = null
var class_system: ClassSystem = null
var data_manager: DataManager = null
var object_pool: ObjectPool = null
var talent_system: TalentSystem = null

var monster_spawn_points: Array = []
var spawned_monsters: Array = []
var respawn_timer: float = 0.0

func _ready():
    setup_systems()
    change_state(GameState.BOOT)

func setup_systems():
    event_bus = EventBus.new()
    add_child(event_bus)
    
    class_system = ClassSystem.new()
    add_child(class_system)
    
    data_manager = DataManager.new()
    data_manager.init()
    add_child(data_manager)
    
    object_pool = ObjectPool.new()
    add_child(object_pool)
    
    talent_system = TalentSystem.new()
    add_child(talent_system)
    
    event_bus.on_death.connect(_on_player_death)
    event_bus.on_revive.connect(_on_player_revive)
    event_bus.on_level_up.connect(_on_player_level_up)

func change_state(new_state: GameState):
    current_state = new_state
    
    match current_state:
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
    change_state(GameState.LOGIN)

func _on_login():
    change_state(GameState.CHARACTER_SELECT)

func _on_character_select():
    change_state(GameState.LOADING)

func _on_loading():
    yield(get_tree(), "idle_frame")
    change_state(GameState.PLAYING)

func _on_playing():
    _spawn_player()
    _setup_monster_spawn_points()
    _spawn_initial_monsters()

func _on_paused():
    get_tree().paused = true

func _on_dead():
    respawn_timer = 5.0

func _on_respawn():
    if player and player.has_method("respawn"):
        player.respawn()
    change_state(GameState.PLAYING)

func _spawn_player():
    var player_scene = load("res://Scenes/Player.tscn")
    if player_scene:
        player = player_scene.instance()
        player.name = "Player"
        player.position = Vector2(400, 450)
        player.add_to_group("player")
        add_child(player)
        
        var player_controller = player.get_script()
        if player_controller and player_controller.has_method("init_player"):
            player_controller.init_player()

func _setup_monster_spawn_points():
    monster_spawn_points = [
        Vector2(150, 500),
        Vector2(250, 500),
        Vector2(350, 500),
        Vector2(550, 500),
        Vector2(650, 500),
        Vector2(750, 500),
        Vector2(150, 400),
        Vector2(650, 400),
        Vector2(250, 350),
        Vector2(550, 350)
    ]

func _spawn_initial_monsters():
    for i in range(min(monster_spawn_points.size(), 8)):
        _spawn_monster_at_point(monster_spawn_points[i])

func _spawn_monster_at_point(point: Vector2):
    var monster_scene = load("res://Scenes/Monster.tscn")
    if monster_scene:
        var monster = monster_scene.instance()
        monster.name = "Monster_" + str(spawned_monsters.size())
        monster.global_position = point
        add_child(monster)
        spawned_monsters.append(monster)
        
        var monster_controller = monster.get_script()
        if monster_controller:
            var monster_data = data_manager.get_monster("red_eye_rabbit")
            monster_controller.init_monster(monster_data)

func _physics_process(delta: float):
    match current_state:
        GameState.PLAYING:
            _process_playing(delta)
        GameState.DEAD:
            _process_dead(delta)

func _process_playing(delta: float):
    _update_monsters(delta)
    _check_monster_count()

func _process_dead(delta: float):
    respawn_timer -= delta
    if respawn_timer <= 0:
        change_state(GameState.RESPAWN)

func _update_monsters(delta: float):
    for monster in spawned_monsters:
        if not is_instance_valid(monster):
            spawned_monsters.erase(monster)

func _check_monster_count():
    if spawned_monsters.size() < 5:
        var available_points = []
        for point in monster_spawn_points:
            var occupied = false
            for monster in spawned_monsters:
                if monster.global_position.distance_to(point) < 50:
                    occupied = true
                    break
            if not occupied:
                available_points.append(point)
        
        if available_points.size() > 0:
            var random_point = available_points[randi() % available_points.size()]
            _spawn_monster_at_point(random_point)

func toggle_pause():
    if current_state == GameState.PLAYING:
        change_state(GameState.PAUSED)
    elif current_state == GameState.PAUSED:
        change_state(GameState.PLAYING)
        get_tree().paused = false

func _on_player_death(player_node: Node, killer: Node):
    change_state(GameState.DEAD)

func _on_player_revive(player_node: Node):
    change_state(GameState.PLAYING)

func _on_player_level_up(player_node: Node, new_level: int):
    pass

func get_event_bus() -> EventBus:
    return event_bus

func get_class_system() -> ClassSystem:
    return class_system

func get_data_manager() -> DataManager:
    return data_manager

func get_object_pool() -> ObjectPool:
    return object_pool

func get_talent_system() -> TalentSystem:
    return talent_system

func get_player() -> Node2D:
    return player