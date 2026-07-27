extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(delta: float):
    var input_dir: Vector2 = Vector2.ZERO
    
    if Input.is_key_pressed(Key.KEY_A) or Input.is_key_pressed(Key.KEY_LEFT):
        input_dir.x -= 1
    if Input.is_key_pressed(Key.KEY_D) or Input.is_key_pressed(Key.KEY_RIGHT):
        input_dir.x += 1
    if Input.is_key_pressed(Key.KEY_W) or Input.is_key_pressed(Key.KEY_UP):
        input_dir.y -= 1
    if Input.is_key_pressed(Key.KEY_S) or Input.is_key_pressed(Key.KEY_DOWN):
        input_dir.y += 1
    
    if input_dir.length() > 0:
        input_dir = input_dir.normalized()
        velocity.x = input_dir.x * speed
        velocity.y = input_dir.y * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.y = move_toward(velocity.y, 0, speed)
    
    move_and_slide()