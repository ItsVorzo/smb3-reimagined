extends EnemyClass  # EnemyClass extends CharacterBody2D

var max_fall_speed := 2000.0   # Optional cap

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()
	sprite.scale.x = direction

	if stomped:
		return

	# Apply gravity
	gravity(delta)
	velocity.y = min(velocity.y, max_fall_speed)

	# Set horizontal speed
	velocity.x = xspd

	# Move the character — no arguments needed in Godot 4.x
	move_and_slide()

	flip_direction()
