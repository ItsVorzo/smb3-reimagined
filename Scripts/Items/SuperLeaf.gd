extends PowerUpItem

var start_x
var x_speed := 0.0
var swinging_direction := 1
var acc_speed := 7.6
var max_speed := 120.0
var gravity := 500.0

func _ready() -> void:
	super._ready()
	start_x = global_position.x
	if from_block:
		x_speed = 0.0
		velocity.y = -200.0

func _physics_process(delta: float) -> void:
	
	if from_block:
		velocity.y += gravity * delta
		move_and_slide()
		if velocity.y >= 0.0:
			from_block = false
		return

	# Leaf oscillation (THANKS WYE XOXO)
	x_speed += acc_speed * swinging_direction

	if abs(x_speed) >= max_speed:
		swinging_direction *= -1
		x_speed = max_speed * sign(x_speed)

	velocity.x = x_speed

	if swinging_direction != sign(x_speed):
		velocity.y = -15.0
	elif swinging_direction == -1:
		velocity.y = 52.5
	else:
		velocity.y = 60.0

	$AnimatedSprite2D.flip_h = x_speed > 0

	move_and_slide()
