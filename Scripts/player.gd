extends CharacterBody2D

class_name Player

# === Tunable Constants ===
const WALK_SPEED = 80.0
const RUN_SPEED = 160.0
const ACCELERATION = 800.0
const AIR_ACCELERATION = 400.0
const FRICTION = 1000.0
const AIR_FRICTION = 200.0

const WALK_JUMP_VELOCITY = -300.0
const RUN_JUMP_VELOCITY = -420.0
const MAX_JUMP_HOLD_TIME = 0.2  # Max duration jump can be held (in seconds)

const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_CUTOFF_MULTIPLIER = 2.0

const COYOTE_TIME = 0.12  # seconds
const JUMP_BUFFER_TIME = 0.1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump = $AudioStreamPlayer2D

# === State ===
var jump_buffer_timer = 0.0
var coyote_timer = 0.0
var jump_held_timer = 0.0
var is_jump_pressed = false
var is_skidding = false
var is_crouching = false
var is_running = false

func _ready() -> void:
	add_to_group("Player")

func bounce():
	velocity.y = -250  # Feel free to tweak

func _physics_process(delta: float) -> void:
	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# === Input ===
	var direction := Input.get_axis("move_left", "move_right")
	is_running = Input.is_action_pressed("run") and direction != 0
	var speed := RUN_SPEED if is_running else WALK_SPEED
	var target_speed := speed * direction
	var accel := ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var friction := FRICTION if is_on_floor() else AIR_FRICTION

	# === Crouching ===
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()
	if is_crouching and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	elif direction != 0:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# === Skid Detection ===
	is_skidding = is_on_floor() and direction != 0 and sign(velocity.x) != sign(direction) and abs(velocity.x) > 20 and Input.is_action_pressed("skid")

	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			velocity.y += gravity * JUMP_CUTOFF_MULTIPLIER * delta
		elif velocity.y > 0:
			velocity.y += gravity * FALL_GRAVITY_MULTIPLIER * delta
		else:
			velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	# === Jumping ===
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		var jump_velocity = RUN_JUMP_VELOCITY if is_running else WALK_JUMP_VELOCITY
		velocity.y = jump_velocity
		is_jump_pressed = true
		jump_held_timer = 0.0
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump.play()

	if is_jump_pressed and Input.is_action_pressed("jump"):
		jump_held_timer += delta
		if jump_held_timer > MAX_JUMP_HOLD_TIME:
			is_jump_pressed = false
	else:
		is_jump_pressed = false

	# === Animation ===
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if is_crouching:
			animated_sprite.play("crouch")
		elif is_skidding:
			animated_sprite.play("skid")
		elif direction == 0:
			animated_sprite.play("idle")
		elif is_running:
			animated_sprite.play("run")
		else:
			animated_sprite.play("walk")
	else:
		if is_crouching:
			animated_sprite.play("crouch")
		else:
			animated_sprite.play("jump")

	# === Move ===
	move_and_slide()
