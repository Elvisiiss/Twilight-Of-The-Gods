extends CharacterBody2D

var speed: float = 300.0
var camera: Camera2D = null

func _ready():
	camera = get_parent().get_parent().get_node("Camera2D")

func _physics_process(delta: float):
	var input_dir: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(Key.A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(Key.D):
		input_dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(Key.W):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(Key.S):
		input_dir.y += 1
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
		move_and_slide()
		
		if camera:
			camera.position = global_position

	if Input.is_action_just_pressed("ui_accept"):
		print("Attack!")
	
	if Input.is_action_just_pressed("ui_cancel"):
		var dodge_dir: Vector2 = input_dir if input_dir.length() > 0 else Vector2.RIGHT
		velocity = dodge_dir * 500
		move_and_slide()