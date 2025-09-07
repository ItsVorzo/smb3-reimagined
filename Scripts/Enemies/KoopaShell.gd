extends CharacterBody2D

@export_enum("Green", "Red") var color := "Green"
@onready var grab = $Grabbable
@onready var stomparea := $StompArea
@onready var hurtbox := $HurtBox
@onready var grabbox := $Grabbox
var xspd := 180.0
var added_xspd := 0.0
var direction := 1
var gravity = 500.0
var bounce_force = -80.0
var has_bounced = true
var was_on_floor = false
var was_grabbed = false 
var is_dead := false

func _ready() -> void:
	add_to_group("Shell")
	hurtbox.body_entered.connect(shell_damage)
	stomparea.body_entered.connect(stomp_on_shell)

func _physics_process(delta: float) -> void:
	var is_currently_grabbed = grab.is_grabbed

	# If the shell dies then make it rotate
	if is_dead:
		$AnimatedSprite2D.rotation += 0.3 * sign(velocity.x)
		velocity.x = xspd * direction

	# === Grab/Kick ===
	# If you didn't grab it
	if not is_currently_grabbed:
		$Collision.disabled = false
		velocity.y += gravity * delta

		# If you didn't kick it
		if not grab.is_kicked:
			$AnimatedSprite2D.play("Idle" + color)
			# Make the shell bounce a little
			if is_on_floor() and not was_on_floor and not has_bounced and velocity.y > 0:
				velocity.y = bounce_force
				has_bounced = true
		# Kick the shell and spin
		else:
			$AnimatedSprite2D.play("Spin" + color, 2 * direction) # Direction is used to change the sprite loop direction
			velocity.x = xspd * direction

	# Stop everything when you're holding it
	else:
		$Collision.disabled = true
		velocity = Vector2.ZERO

	# Reset bounce if it was just released
	if was_grabbed and not is_currently_grabbed:
		has_bounced = false

	# Update checks
	was_on_floor = is_on_floor()
	was_grabbed = is_currently_grabbed

	move_and_slide()

	# Change direction on wall 
	if not is_dead:
		if is_on_wall():
			if not grab.is_grabbed: SoundManager.play_sfx("Hit", global_position)
			direction *= -1


func stomp_on_shell(body: Node):
	if body.is_in_group("Player") and grab.grab_delay == 0 and grab.is_kicked:
		if body.velocity.y > 0:
			SoundManager.play_sfx("Stomp", global_position)
			body.bounce_on_enemy()
			grab.is_kicked = false
			grab.grab_delay = 10
			velocity.x = 0

# Interact with objects
func shell_damage(body: Node):
	# Collide with the player
	if body.is_in_group("Player"):
		if grab.is_kicked and grab.grab_delay == 0 or grab.holder != null and body.current_grabbed_obj != $Grabbable:
			body.damage()

	# Kill while being grabbed
	elif grab.is_grabbed and ((body != self and body.is_in_group("Shell")) or body.is_in_group("Enemies")):
		if grab.holder:
			grab.holder.current_grabbed_obj = null
			grab.is_grabbed = false
		SoundManager.play_sfx("Kick", global_position)
		die(-direction)
		if body.is_in_group("Shell"):
			body.die(-direction)
		else:
			body.die_from_obj(-direction)

	elif (body != self and body.is_in_group("Shell") or body.is_in_group("Enemies")) and grab.is_kicked:
		SoundManager.play_sfx("Kick", global_position)
		if body.is_in_group("Shell"):
			body.die(direction)
		else:
			body.die_from_obj(direction)

func die(dir := 1):
	is_dead = true
	velocity.y = -130
	direction = dir
	xspd = 130
	$Collision.set_deferred("disabled", true)
	set_collision_layer(0)
	set_collision_mask(0)
	collision_mask = 0
	hurtbox.set_deferred("monitoring", false)
	stomparea.set_deferred("monitoring", false)
	grabbox.set_deferred("monitoring", false)
