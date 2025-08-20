extends CharacterBody2D
class_name Player

# === Tunable Constants ===
const walk_speed = 90.0
const run_speed = 150.0
const p_speed = 210.0
const acc_speed = 3.28125
const frc_speed = 3.28125
const skid_speed = 7.5

const jump_force = [-217.5, -225.0, -240, -258.75]

const coyote_time = 0.1
const jump_buffer_time = 0.1

var p_meter = 0.0
var p_meter_max = 70.0
var previous_max_speed = walk_speed
var max_speed = walk_speed
var grav_speed = 800.0
var velocity_direction = sign(velocity.x)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump = $AudioStreamPlayer2D
@onready var normal_collision_shape := $CollisionShape2D
@onready var super_collision_shape := $SuperCollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var bottom_pit := $"../CameraGroundLimit"

# === State ===
var jump_buffer_timer = 0.0
var coyote_timer = 0.0
var is_skidding = false

var facing_direction := 1
var is_super := false

# === Death state (adds on top of old script, doesn't affect normal physics) ===
var is_dead := false
var death_state := "idle"   # "idle", "pause", "jump", "fall"

func _process(delta):
	# === Set the sprite x scale ===
	if is_on_floor():
		if InputManager.direction != 0 and sign(velocity.x) == InputManager.direction:
			facing_direction = InputManager.direction
	elif InputManager.direction != 0:
		facing_direction = InputManager.direction
	animated_sprite.scale.x = facing_direction

	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	if InputManager.Apress:
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# === Set max speeds ===
	if p_meter < p_meter_max:
		if InputManager.B:
			max_speed = run_speed
			if abs(velocity.x) < run_speed: previous_max_speed = walk_speed
			else: previous_max_speed = run_speed
		else:
			max_speed = walk_speed
			if abs(velocity.x) > walk_speed + 3: previous_max_speed = run_speed
	else:
		max_speed = p_speed
		previous_max_speed = run_speed
	if is_skidding or abs(velocity.x) < walk_speed: previous_max_speed = walk_speed

	# === P meter ===
	p_meter = clamp(p_meter, 0, p_meter_max)
	if abs(velocity.x) >= run_speed and InputManager.B:
		p_meter += 1
	elif p_meter > 0 or (not is_on_floor() and p_meter >= p_meter_max):
		p_meter -= 0.583

func power_up():
	if is_super:
		return
	is_super = true
	print("Mario powered up!")

	normal_collision_shape.disabled = true
	super_collision_shape.disabled = false

	animated_sprite.play("power_up")

func bounce_on_enemy() -> void:
	if InputManager.A:
		velocity.y = -240.0
	else:
		velocity.y = -180.0

func _ready() -> void:
	add_to_group("Player")  # <-- fixed group name
	super_collision_shape.disabled = true

func _physics_process(delta: float) -> void:
	# ======= DEATH OVERRIDE (added) =======
	if is_dead:
		match death_state:
			"pause":
				velocity.x = 0
				animated_sprite.play("dead")
				# wait for Level.gd to push us to "jump"
			"jump", "fall":
				animated_sprite.play("dead")
				# custom gravity; no normal physics while dead
				velocity.y += grav_speed * delta
				move_and_slide()
		return
	# ======= END DEATH OVERRIDE =======

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
				elif previous_max_speed > max_speed:
					velocity.x -= frc_speed
				else:
					velocity.x = max_speed
		elif InputManager.direction == -1:
			if velocity.x > 0:
				velocity.x -= skid_speed
				is_skidding = true
			else:
				is_skidding = false
				if velocity.x > -max_speed:
					velocity.x -= acc_speed
				elif -previous_max_speed < -max_speed:
					velocity.x += frc_speed
				else:
					velocity.x = -max_speed

	if InputManager.direction == 0 and is_on_floor() or InputManager.down and is_on_floor():
		velocity.x -= min(abs(velocity.x), frc_speed) * sign(velocity.x)
	#print(InputManager.direction, " + ", velocity.x, " + ", max_speed, " + ", p_meter)
	#print(previous_max_speed > max_speed)
	#print(previous_max_speed, " + ", max_speed, " current speed: ", velocity.x)

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
	var final_grav_speed: float
	if not is_on_floor():
		if velocity.y < -120 and InputManager.A: final_grav_speed = 256.0
		else: final_grav_speed = 1280.0
	if not is_on_floor(): velocity.y += final_grav_speed * delta
	velocity.y = min(velocity.y, 240)

	# === Jumping ===
	if InputManager.Apress and jump_buffer_timer > 0.0 and coyote_timer > 0.0 or InputManager.Apress and is_on_floor():
		var dx = floor(abs(velocity.x)/60)
		velocity.y = jump_force[dx]
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jump.play()

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
			animated_sprite.play("run", 6)
	else:
		if InputManager.down:
			animated_sprite.play("crouch")
		elif max_speed != p_speed:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fly")

	# Player dies when you fall in a pit
	if !is_dead && is_instance_valid(bottom_pit):
		if global_position.y > bottom_pit.global_position.y + 48: die()

	move_and_slide()

# ======= Death entry point (added) =======
func die() -> void:
	if is_dead:
		return
	velocity.x = 0
	is_dead = true
	InputManager.input_disabled = true

	# Freeze the game
	get_tree().paused = true

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
