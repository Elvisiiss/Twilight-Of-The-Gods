extends Node2D

@onready var camera = $Camera2D
@onready var player = $Player

func _ready():
    $Background.color = Color(0.1, 0.15, 0.25)
    $Player/PlayerSprite.color = Color(0.2, 0.8, 0.3)
    camera.position = player.global_position

func _process(delta: float):
    if player:
        camera.position = player.global_position