extends EnemyClass

var xspd := -30.0              # Horizontal speed
var gravity := 1000.0          # Gravity force
var max_fall_speed := 2000.0   # Optional cap
var stomp_sound_played := false  # Ensure sound is played only once

func _ready() -> void:
	set_signals()

func _physics_process(delta: float) -> void:
	if stomped:
		if not stomp_sound_played:
			$StompSound.play()
			stomp_sound_played = true
			$Sprite.play("squish")
		
		# Optional: Stop movement or kill the enemy
		velocity = Vector2.ZERO
		move_and_slide()
		return

	process()

	# Apply gravity
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)

	# Set horizontal speed
	velocity.x = xspd

	move_and_slide()

	# Turn around when hitting a wall
	if is_on_wall():
		xspd *= -1
		flip_sprite()

func flip_sprite() -> void:
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sprite.scale.x *= -1
