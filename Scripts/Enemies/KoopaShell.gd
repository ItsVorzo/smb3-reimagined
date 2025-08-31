extends CharacterBody2D

@onready var grab = $Grabbable
@onready var stomparea := $StompArea
@onready var hurtbox := $HurtBox
@onready var grabbox := $Grabbox
var xspd := 180
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

	if is_dead:
		$AnimatedSprite2D.rotation += 0.4 * sign(abs(velocity.x))

	# === Grab/Kick ===
	# If you didn't grab it
	if not is_currently_grabbed:
		$Collision.disabled = false
		velocity.y += gravity * delta

		# If you didn't kick it
		if not grab.is_kicked:
			$AnimatedSprite2D.play("Idle")
			# Make the shell bounce a little
			if is_on_floor() and not was_on_floor and not has_bounced and velocity.y > 0:
				velocity.y = bounce_force
				has_bounced = true
		# Kick the shell and spin
		else:
			$AnimatedSprite2D.play("Spin", 2 * direction) # Direction is used to change the sprite loop direction
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
			if not is_dead: direction *= -1
			if not grab.is_grabbed: SoundManager.play_sfx("Hit", global_position)

func stomp_on_shell(body: Node):
	if body.is_in_group("Player") and grab.grab_delay == 0 and grab.is_kicked:
		if body.velocity.y > 0:
			SoundManager.play_sfx("Stomp", global_position)
			body.bounce_on_enemy()
			grab.is_kicked = false
			grab.grab_delay = 10
			velocity.x = 0

func shell_damage(body: Node):
	if body.is_in_group("Player"):
		if grab.is_kicked and grab.grab_delay == 0 or grab.holder != null and body.current_grabbed_obj != $Grabbable:
			body.damage()
	elif body != self and body.is_in_group("Shell"):
		SoundManager.play_sfx("Kick", global_position)
		is_dead = true
		die(body)
		body.die(self)

func die(body: Node):
	velocity.y = -130
	xspd = body.xspd / 1.2
	$Collision.set_deferred("disabled", true)
	set_collision_layer(0)
	set_collision_mask(0)
	collision_mask = 0
	hurtbox.set_deferred("monitoring", false)
	stomparea.set_deferred("monitoring", false)
	grabbox.set_deferred("monitoring", false)
