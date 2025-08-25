extends EnemyClass  # EnemyClass extends CharacterBody2D

var xspd := -30.0              # Horizontal speed
var gravity := 1000.0          # Gravity force
var max_fall_speed := 2000.0   # Optional cap

func _ready() -> void:
	set_signals()

func _physics_process(delta: float) -> void:
	process()

	if stomped:
		$Sprite.play("squish")
		return

	# Apply gravity
	velocity.y += gravity * delta
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
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sprite.scale.x *= -1
