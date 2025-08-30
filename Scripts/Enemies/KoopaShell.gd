extends CharacterBody2D

@onready var grab = $Grabbable
@onready var stomparea := $StompArea
@onready var hurtbox := $HurtBox
var xspd := 180
var direction := 1
var gravity = 500.0
var bounce_force = -80.0
var has_bounced = true
var was_on_floor = false
var was_grabbed = false 

func _ready() -> void:
	hurtbox.body_entered.connect(shell_damage)
	stomparea.body_entered.connect(stomp_on_shell)

func _physics_process(delta: float) -> void:
	var is_currently_grabbed = grab.is_grabbed

	# === Grab/Kick ===
	# If you didn't grab it
	if not is_currently_grabbed:
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
		velocity = Vector2.ZERO

	# Reset bounce if it was just released
	if was_grabbed and not is_currently_grabbed:
		has_bounced = false

	# Update checks
	was_on_floor = is_on_floor()
	was_grabbed = is_currently_grabbed

	move_and_slide()

	# Change direction on wall 
	if is_on_wall():
		direction *= -1
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
		if grab.is_kicked and grab.grab_delay == 0:
			body.damage()
