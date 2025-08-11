extends CharacterBody2D

class_name Player

# === Tunable Constants ===
const walk_speed = 80.0
const run_speed = 160.0
const acc_speed = 800.0
const grav_speed = 400.0
const fric_speed = 1000.0
const air_fric_speed = 200.0

const base_jump = -420.0
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
@onready var normal_collision_shape := $CollisionShape2D
@onready var super_collision_shape := $SuperCollisionShape2D

# === State ===
var jump_buffer_timer = 0.0
var coyote_timer = 0.0
var jump_held_timer = 0.0
var is_jump_pressed = false
var is_skidding = false
var is_crouching = false
var is_running = false

var facing_direction := 1  # 1 = right, -1 = left

var is_super := false  # Super Mario state flag

func _process(_delta):
	if InputManager.right:
		facing_direction = 1
	elif InputManager.left:
		facing_direction = -1

func get_facing_direction() -> int:
	return facing_direction

func power_up():
	if is_super:
		return  # Already powered up, ignore

	is_super = true
	print("Mario powered up!")

	# Switch collision shapes
	normal_collision_shape.disabled = true
	super_collision_shape.disabled = false

	# Play power-up animation or effect
	animated_sprite.play("power_up")

	# Optionally scale sprite (uncomment if you want)
	# animated_sprite.scale = Vector2(1.5, 1.5)

func bounce():
	velocity.y = -300  # Adjust as needed
	
func play_squish_sound():
	$SquishSoundPlayer.play()

func _ready() -> void:
	add_to_group("Player")
	# Ensure super collision shape disabled by default
	super_collision_shape.disabled = true

func _physics_process(delta: float) -> void:
	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	if InputManager.Apress:
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# === Move ===
	var direction := Input.get_axis("left", "right")
	is_running = InputManager.B and direction != 0
	var speed := run_speed if is_running else walk_speed
	var target_speed := speed * direction
	var accel := acc_speed if is_on_floor() else grav_speed
	var friction := fric_speed if is_on_floor() else air_fric_speed

	# === Crouching ===
	is_crouching = InputManager.down and is_on_floor()
	if is_crouching and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	elif direction != 0:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# === Skid Detection ===
	is_skidding = is_on_floor() and direction != 0 and sign(velocity.x) != sign(direction) and abs(velocity.x) > 20 and Input.is_action_pressed("skid") #skid input???

	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < 0 and not InputManager.A:
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

	if is_jump_pressed and InputManager.A:
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
