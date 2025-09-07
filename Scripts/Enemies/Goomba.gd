extends EnemyClass

func _ready() -> void:
	init()

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()

	if stomped:
		sprite.scale.x = direction
		sprite.play("squish")
		velocity = Vector2.ZERO
		return

	# Apply gravity
	if not is_on_floor():
		gravity(delta)
	velocity.y = min(velocity.y, grav_speed)

	move_and_slide()

	# Turn around when hitting a wall
	flip_direction()
