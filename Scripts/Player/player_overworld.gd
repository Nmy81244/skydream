extends CharacterBody2D

var speed = 130.0
var walking = false
var running = false
var input_dir = Vector2.ZERO
var direction = 0 # 0D - 1L - 2U - 3R

func _physics_process(_delta: float) -> void:
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_pressed("Run"):
		running = true
	else:
		running = false
	
	if running:
		speed = 200.0
		velocity = input_dir.normalized() * speed
	else:
		speed = 130.0
		velocity = input_dir * speed	
		
	if input_dir != Vector2.ZERO:
		if abs(input_dir.x) > abs(input_dir.y):
			if input_dir.x > 0:
				direction = 3 # Right
			else:
				direction = 1 # Left
		else:
			if input_dir.y > 0:
				direction = 0 # Down
			else:
				direction = 2 # Up
			
	if input_dir == Vector2.ZERO:
		walking = false
		render_animations()
	else:
		walking = true
		render_animations()
	
	move_and_slide()

func render_animations():
	if !walking:
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.frame = direction
		
	elif running:
		$AnimatedSprite2D.play("run_%s" % direction)
		$AnimatedSprite2D.speed_scale = clamp(input_dir.length(), 0.3, 1.0)
		
	elif walking:
		$AnimatedSprite2D.play("walk_%s" % direction)
		$AnimatedSprite2D.speed_scale = clamp(input_dir.length(), 0.3, 1.0)
		

		
