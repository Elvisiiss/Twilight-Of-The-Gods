extends CharacterBody2D

@export var speed: float = 300.0
@export var gravity: float = 2000.0
@export var jump_force: float = -700.0

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float):
    var input_dir: Vector2 = Vector2.ZERO
    
    if Input.is_key_pressed(Key.A) or Input.is_key_pressed(Key.LEFT):
        input_dir.x -= 1
    if Input.is_key_pressed(Key.D) or Input.is_key_pressed(Key.RIGHT):
        input_dir.x += 1
    if Input.is_key_pressed(Key.W) or Input.is_key_pressed(Key.UP):
        input_dir.y -= 1
    if Input.is_key_pressed(Key.S) or Input.is_key_pressed(Key.DOWN):
        input_dir.y += 1
    
    if input_dir.length() > 0:
        input_dir = input_dir.normalized()
        velocity.x = input_dir.x * speed
        velocity.y = input_dir.y * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.y = move_toward(velocity.y, 0, speed)
    
    move_and_slide()