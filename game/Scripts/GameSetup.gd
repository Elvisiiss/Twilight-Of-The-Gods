extends Node2D

func _ready():
    $World/Background.color = Color(0.1, 0.15, 0.25)
    $World/Ground/GroundSprite.color = Color(0.2, 0.3, 0.4)
    $World/Ground/GroundCollision.shape = RectangleShape2D.new()
    $World/Ground/GroundCollision.shape.size = Vector2(2000, 100)
    $World/Player/PlayerSprite.color = Color(0.2, 0.8, 0.3)
    $World/Player/PlayerCollision.shape = RectangleShape2D.new()
    $World/Player/PlayerCollision.shape.size = Vector2(30, 50)