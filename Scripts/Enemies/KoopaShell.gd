extends CharacterBody2D

# === Shell info ===
@export_enum("Green", "Red") var color := "Green"
@export var is_empty := true

# === General shell stuff ===
@onready var grab = $Grabbable
@onready var stomparea := $StompArea
@onready var hurtbox := $HurtBox
@onready var grabbox := $Grabbox
@onready var sprite := $AnimatedSprite2D
@onready var collision := $Collision
var xspd := 180.0
var added_xspd := 0.0
var direction := 1
var gravity = 600.0
var bounce_force = -80.0
var can_bounce = false
var is_dead := false

func _ready() -> void:
	add_to_group("Shell")
	hurtbox.body_entered.connect(shell_damage)
	hurtbox.area_entered.connect(shell_damage)
	stomparea.body_entered.connect(stomp_on_shell)

	sprite.play("Idle" + color)

func _physics_process(delta: float) -> void:
	if is_dead:
		sprite.rotation += 0.3 * sign(velocity.x)
		velocity.x = xspd * direction

	if grab.is_just_released:
		can_bounce = true

	# === Grab/Kick ===
	# If you aren't holding it
	if not grab.is_grabbed:
		collision.disabled = false
		velocity.y += gravity * delta

		# If you didn't kick it
		if not grab.is_kicked:
			sprite.play("Idle" + color)
			# Make the shell bounce a little
			if is_on_floor() and can_bounce:
				velocity.y = bounce_force
				can_bounce = false
		# Kick the shell and spin
		else:
			sprite.play("Spin" + color, 2 * direction) # Direction is used to change the sprite loop direction
			velocity.x = xspd * direction

	# Stop everything when you're holding it
	else:
		collision.disabled = true
		velocity = Vector2.ZERO

	move_and_slide()

	# Change direction on wall 
	if not is_dead:
		if is_on_wall():
			if not grab.is_grabbed: SoundManager.play_sfx("Hit", global_position)
			direction *= -1

# === Stomp da shell ===
func stomp_on_shell(body):
	if body.is_in_group("Player") and grab.grab_delay == 0 and grab.is_kicked:
		if not body.is_on_floor():
			SoundManager.play_sfx("Stomp", global_position)
			body.bounce_on_enemy()
			grab.is_kicked = false
			grab.grab_delay = 10
			velocity.x = 0

# === Interact with objects ===
func shell_damage(body: Node):
	# Kill the player
	if body.is_in_group("Player"):
		if grab.is_kicked and grab.grab_delay == 0:
			body.damage()

	# Kill while being grabbed
	elif grab.is_grabbed and ((body != self and body.is_in_group("Shell")) or body.is_in_group("Enemies")):
		# Get rid of the holder
		if grab.holder:
			grab.holder.current_grabbed_obj = null
			grab.is_grabbed = false

		SoundManager.play_sfx("Kick", global_position)
		# Kill the shell/enemy
		die(-direction) # kills themselves
		if body.is_in_group("Shell"):
			body.die(-direction)
		else:
			body.die_from_obj(-direction)

	# Kill while spinning
	elif (body != self and body.is_in_group("Shell") or body.is_in_group("Enemies")) and grab.is_kicked:
		SoundManager.play_sfx("Kick", global_position)
		if body.is_in_group("Shell"):
			body.die(direction)
		else:
			body.die_from_obj(direction)

# === Basically die_from_obj but for shells ===
func die(dir := 1, spd := 130):
	is_dead = true
	velocity.y = -130
	direction = dir
	xspd = spd
	collision.set_deferred("disabled", true)
	set_collision_layer(0)
	set_collision_mask(0)
	hurtbox.set_deferred("monitoring", false)
	stomparea.set_deferred("monitoring", false)
	grabbox.set_deferred("monitoring", false)
