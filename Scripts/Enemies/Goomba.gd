extends EnemyClass

@export var wings := false
@export var micro_goombas := "does nothing yet"
@onready var r_wing = $RightWing
@onready var l_wing = $LeftWing
var wait_timer := 0.0
var jump_counter := 0
var hop := -90.0
var big_jump := -170.0

func _ready() -> void:
	if wings:
		has_custom_stomp = true
		r_wing.show()
		l_wing.show()
		r_wing.position = Vector2(6, -8)
		l_wing.position = Vector2(-6, -8)
	else:
		r_wing.hide()
		l_wing.hide()
	init()

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()

	if stomped:
		sprite.scale.x = direction
		sprite.play("squish")
		velocity = Vector2.ZERO
		return
	if dead_from_obj:
		r_wing.stop()
		l_wing.stop()
		r_wing.hide()
		l_wing.hide()

	# Apply gravity
	if not is_on_floor():
		gravity(delta)
	velocity.y = min(velocity.y, grav_speed)

	# Hopping and jumping
	if wings:
		# 3 hops
		if wait_timer <= 0.0:
			if is_on_floor():
				velocity.y = hop
				jump_counter += 1
		# Reset the counter
		else:
			if is_on_floor() and jump_counter == 3:
				jump_counter = 0
		# Big jump
		if jump_counter == 3:
			if is_on_floor():
				velocity.y = big_jump
				wait_timer = 30.0

		if wait_timer > 0.0 and is_on_floor():
			wait_timer -= 1

		# Wing flapping animation
		if jump_counter < 3:
			r_wing.stop()
			l_wing.stop()
			if wait_timer == 0:
				if velocity.y > 0:
					r_wing.frame = 0
					l_wing.frame = 0
				else:
					r_wing.frame = 1
					l_wing.frame = 1
			else:
				r_wing.frame = 1
				l_wing.frame = 1
		else:
			if velocity.y < 0:
				r_wing.play("flap", 3)
				l_wing.play("flap", 3)
			else:
				r_wing.play("flap")
				l_wing.play("flap")

	move_and_slide()

	# Turn around when hitting a wall
	flip_direction()

# Get the wings off
func on_stomped() -> void:
	if velocity.y < 0:
		velocity.y = 0
	wings = false
	r_wing.hide()
	l_wing.hide()
	has_custom_stomp = false
