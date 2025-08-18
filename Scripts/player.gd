extends CharacterBody2D
class_name Player

# === Tunable Constants ===
const walk_speed = 90.0
const run_speed = 150.0
const p_speed = 210.0
const acc_speed = 3.75
const air_acc_speed = 400.0
const frc_speed = 3.75
const skid_speed = 10.0
const air_frc_speed = 200.0

const base_jump = -420.0
const WALK_JUMP_VELOCITY = -300.0
const RUN_JUMP_VELOCITY = -420.0
const MAX_JUMP_HOLD_TIME = 0.2

const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_CUTOFF_MULTIPLIER = 2.0

const COYOTE_TIME = 0.12
const JUMP_BUFFER_TIME = 0.1

var p_meter = 0.0
var p_meter_max = 70.0
var max_speed = 0.0
var grav_speed = 800.0
var velocity_direction = sign(velocity.x)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump = $AudioStreamPlayer2D
@onready var normal_collision_shape := $CollisionShape2D
@onready var super_collision_shape := $SuperCollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer

# === State ===
var jump_buffer_timer = 0.0
var coyote_timer = 0.0
var jump_held_timer = 0.0
var is_jump_pressed = false
var is_skidding = false
var is_crouching = false
var is_running = false

var facing_direction := 1
var is_super := false

# === Death state (adds on top of old script, doesn't affect normal physics) ===
var is_dead := false
var death_state := "idle"   # "idle", "pause", "jump", "fall"

func _process(_delta):
	# === Set the sprite x scale ===
	if is_on_floor():
		if InputManager.direction != 0 and sign(velocity.x) == InputManager.direction:
			facing_direction = InputManager.direction
	elif InputManager.direction != 0:
		facing_direction = InputManager.direction
	animated_sprite.scale.x = facing_direction

	# === Set max speeds ===
	if InputManager.B:
		max_speed = run_speed
	else:
		max_speed = walk_speed

	# === P meter ===
	p_meter = clamp(p_meter, 0, p_meter_max)
	if abs(velocity.x) >= run_speed and InputManager.B and is_on_floor():
		p_meter += 1
	else:
		p_meter -= 1
	if p_meter < 0:
		p_meter = 0

func power_up():
	if is_super:
		return
	is_super = true
	print("Mario powered up!")

	normal_collision_shape.disabled = true
	super_collision_shape.disabled = false

	animated_sprite.play("power_up")

func bounce_on_enemy() -> void:
	if Input.is_action_pressed("A"):
		velocity.y = -400.0
	else:
		velocity.y = -300.0

func _ready() -> void:
	add_to_group("Player")  # <-- fixed group name
	super_collision_shape.disabled = true

func _physics_process(delta: float) -> void:
	# ======= DEATH OVERRIDE (added) =======
	if is_dead:
		match death_state:
			"pause":
				velocity = Vector2.ZERO
				animated_sprite.play("dead")
				# wait for Level.gd to push us to "jump"
			"jump", "fall":
				animated_sprite.play("dead")
				# custom gravity; no normal physics while dead
				velocity.y += grav_speed * delta
				move_and_slide()
		return
	# ======= END DEATH OVERRIDE =======

	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	if InputManager.Apress:
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# === Horizontal Movement ===
	if !InputManager.input_disabled or !InputManager.direction_disabled or !InputManager.x_direction_disabled:
		if InputManager.direction == 1:
			if velocity.x < 0:
				velocity.x += skid_speed
				is_skidding = true
			else:
				is_skidding = false
				if velocity.x < max_speed:
					velocity.x += acc_speed
				else:
					velocity.x -= frc_speed
		elif InputManager.direction == -1:
			if velocity.x > 0:
				velocity.x -= skid_speed
				is_skidding = true
			else:
				is_skidding = false
				if velocity.x > -max_speed:
					velocity.x -= acc_speed
				else:
					velocity.x += frc_speed

	if InputManager.direction == 0 or InputManager.input_disabled or InputManager.direction_disabled or InputManager.x_direction_disabled:
		velocity.x -= min(abs(velocity.x), frc_speed) * sign(velocity.x)
	print(InputManager.direction, " + ", velocity.x, " + ", max_speed, " + ", p_meter)

	if is_on_floor():
		if InputManager.down:
			InputManager.x_direction_disabled = true
			velocity.x -= min(abs(velocity.x), frc_speed) * sign(velocity.x)
		else:
			InputManager.x_direction_disabled = false
	else:
		InputManager.x_direction_disabled = false

	if velocity.x == 0:
		is_skidding = false

	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < 0 and not InputManager.A:
			velocity.y += grav_speed * JUMP_CUTOFF_MULTIPLIER * delta
		elif velocity.y > 0:
			velocity.y += grav_speed * FALL_GRAVITY_MULTIPLIER * delta
		else:
			velocity.y += grav_speed * delta
	else:
		velocity.y = 0.0

	if velocity.y > 470:
		velocity.y = 470

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
	if is_on_floor():
		if InputManager.down:
			animated_sprite.play("crouch")
		elif is_skidding:
			animated_sprite.play("skid")
		elif velocity.x == 0:
			animated_sprite.play("idle")
		elif abs(velocity.x) > 0 and max_speed != p_speed:
			animated_sprite.play("walk", max(1, 0.03 * abs(velocity.x)))
		elif max_speed == p_speed:
			animated_sprite.play("run", 1)
	else:
		if InputManager.down:
			animated_sprite.play("crouch")
		else:
			animated_sprite.play("jump")

	move_and_slide()

# ======= Death entry point (added) =======
func die() -> void:
	if is_dead:
		return
	is_dead = true
	InputManager.input_disabled = true

	# Play death animation immediately
	animated_sprite.play("dead")

	# Disable collisions so Mario phases through everything
	normal_collision_shape.disabled = true
	super_collision_shape.disabled = true
	set_collision_layer(0)
	set_collision_mask(0)

	# Freeze the active camera exactly here (works no matter where the camera node lives)
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("freeze_here"):
		cam.freeze_here()

	# Stop all motion until Level.gd starts the death jump
	velocity = Vector2.ZERO
	death_state = "pause"

	# Notify level
	if get_tree().current_scene.has_method("on_player_death"):
		get_tree().current_scene.on_player_death(self)
# ======= End death entry point =======
