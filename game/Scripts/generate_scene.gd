extends Node2D

func _ready():
    var scene := PackedScene.new()
    var main := Node2D.new()
    main.name = "Main"
    
    var camera := Camera2D.new()
    camera.name = "Camera2D"
    camera.make_current()
    main.add_child(camera)
    
    var world := Node2D.new()
    world.name = "World"
    main.add_child(world)
    
    var bg := ColorRect.new()
    bg.name = "Background"
    bg.position = Vector2(-1000, -500)
    bg.size = Vector2(2000, 1500)
    bg.color = Color(0.1, 0.15, 0.25)
    world.add_child(bg)
    
    var ground := StaticBody2D.new()
    ground.name = "Ground"
    ground.position = Vector2(0, 550)
    world.add_child(ground)
    
    var ground_collision := CollisionShape2D.new()
    ground_collision.name = "GroundCollision"
    ground_collision.shape = RectangleShape2D.new()
    ground_collision.shape.size = Vector2(2000, 100)
    ground.add_child(ground_collision)
    
    var ground_sprite := ColorRect.new()
    ground_sprite.name = "GroundSprite"
    ground_sprite.position = Vector2(-1000, -50)
    ground_sprite.size = Vector2(2000, 100)
    ground_sprite.color = Color(0.2, 0.3, 0.4)
    ground.add_child(ground_sprite)
    
    var player := CharacterBody2D.new()
    player.name = "Player"
    player.position = Vector2(400, 300)
    world.add_child(player)
    
    var player_sprite := ColorRect.new()
    player_sprite.name = "PlayerSprite"
    player_sprite.position = Vector2(-15, -50)
    player_sprite.size = Vector2(30, 50)
    player_sprite.color = Color(0.2, 0.8, 0.3)
    player.add_child(player_sprite)
    
    var player_collision := CollisionShape2D.new()
    player_collision.name = "PlayerCollision"
    player_collision.shape = RectangleShape2D.new()
    player_collision.shape.size = Vector2(30, 50)
    player.add_child(player_collision)
    
    scene.pack(main)
    ResourceSaver.save(scene, "res://Scenes/Main.tscn")
    print("Scene generated successfully")
    get_tree().quit()