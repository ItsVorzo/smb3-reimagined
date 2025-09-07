extends EnemyClass  # EnemyClass extends CharacterBody2D

var max_fall_speed := 2000.0   # Optional cap

func _ready() -> void:
	init()

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()
	if stomped:
		return

	# Apply gravity
	gravity(delta)
	velocity.y = min(velocity.y, max_fall_speed)

	# Set horizontal speed
	velocity.x = xspd

	# Move the character — no arguments needed in Godot 4.x
	move_and_slide()

	# Turn around when hitting a wall
	if is_on_wall():
		xspd *= -1
		flip_sprite()

func flip_sprite() -> void:
	var spr = get_node_or_null("Sprite")
	if spr:
		spr.scale.x *= -1
