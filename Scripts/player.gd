class_name Player
extends CharacterBody2D

# === Shortcuts ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump = $AudioStreamPlayer2D
@onready var normal_collision_shape := $CollisionShape2D
@onready var super_collision_shape := $SuperCollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var bottom_pit := $"../CameraGroundLimit"
var character_index = SaveManager.runtime_data.get("character_index", 0)
var character = ["Mario", "Luigi", "Toad", "Toadette"]

# === Physics values ===
var walk_speed = PhysicsVal.walk_speed[character_index]
var run_speed = PhysicsVal.run_speed[character_index]
var p_speed = PhysicsVal.p_speed[character_index]
var acc_speed = PhysicsVal.acc_speed[character_index]
var frc_speed = PhysicsVal.frc_speed[character_index]
var ice_frc_speed = PhysicsVal.ice_frc_speed[character_index]
var skid_speed = PhysicsVal.skid_speed[character_index]
var ice_skid_speed = PhysicsVal.ice_skid_speed[character_index]
var end_level_walk = PhysicsVal.end_level_walk
var airship_cutscene_walk = PhysicsVal.airship_cutscene_walk
var added_gentle_slope_speed = PhysicsVal.added_gentle_slope_speed[character_index]
var added_steep_slope_speed = PhysicsVal.added_steep_slope_speed[character_index]
var uphill_max_walk = PhysicsVal.uphill_max_walk[character_index]
var uphill_max_run = PhysicsVal.uphill_max_run[character_index]
var gentle_sliding_acc = PhysicsVal.gentle_sliding_acc[character_index]
var steep_sliding_acc = PhysicsVal.steep_sliding_acc[character_index]
var sliding_max_speed = PhysicsVal.sliding_max_speed

var jump_speeds = PhysicsVal.jump_speeds.slice(character_index * 4, 4)
var strong_bounce = PhysicsVal.strong_bounce[character_index]
var weak_bounce = PhysicsVal.weak_bounce[character_index]

var low_gravity = PhysicsVal.low_gravity[character_index]
var high_gravity = PhysicsVal.high_gravity[character_index]
const death_gravity = 420.0

# === Other stuff ===
var final_grav_speed: float
var direction_allow := true
var facing_direction := 1.0
var velocity_direction := 0.0
const coyote_time = 0.1
const jump_buffer_time = 0.1

var p_meter = 0.0
var p_meter_max = 70.0
var extra_p_frames = 16.0
var max_speed = 0.0

# === States ===
@onready var state_machine: StateMachine = $States
@export var pwrup: PowerUps = null
var current_powerup: int = 0
var jump_buffer_timer = 0.12
var coyote_timer = 0.12
var crouching
var skidding = false
var is_super := false
var can_take_damage := true
var is_dead := false

func _ready() -> void:

	add_to_group("Player")  # <-- fixed group name

# === Logic ===
func _process(delta):

	# === Set variables ===
	max_speed = final_max_speed()
	p_meter = handle_p_meter()
	skidding = InputManager.direction != 0 and velocity_direction != 0 and InputManager.direction != velocity_direction
	animated_sprite.scale.x = sprite_direction()
	velocity_direction = sign(velocity.x)

	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	if InputManager.Apress:
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= 1

	is_super = pwrup.tier >= 1
	normal_collision_shape.disabled = is_super
	super_collision_shape.disabled = not is_super

# === Physics ===
func _physics_process(delta: float) -> void:

	if is_dead:
		return
	#print(InputManager.direction, " + ", velocity.x, " + ", max_speed, " + ", p_meter)

	# Reset skidding
	if InputManager.direction == 0:
		skidding = false

	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < -120 and InputManager.A: final_grav_speed = low_gravity
		else: final_grav_speed = high_gravity
		velocity.y += final_grav_speed * delta
		velocity.y = min(velocity.y, 258.75)
	# Jumping
	if InputManager.Apress and is_on_floor():
		var final_jump_speed = floor(abs(velocity.x)/60)
		velocity.y = jump_speeds[final_jump_speed]
		jump.play()

	# Player dies when you fall in a pit
	if !is_dead && is_instance_valid(bottom_pit):
		if global_position.y > bottom_pit.global_position.y + 50: die()

	move_and_slide()

	# === Set the sprite x scale ===
func sprite_direction():
	if direction_allow && InputManager.direction != 0:
		facing_direction = InputManager.direction
	return facing_direction

# === Bounce on koopalings ===
func bounce_on_enemy() -> void:
	if state_machine.state.name != "Normal":
		state_machine.change_state("Normal")
	if InputManager.A:
		velocity.y = -240.0
	else:
		velocity.y = -180.0

# === DIE! ===
func die() -> void:
	if state_machine.state.name == "Die":
		return
	state_machine.change_state("Die")

# === Deal damage ===
func damage() -> void:
	# If you're small DIE
	if pwrup.tier == 0:
		return die()

	# Become either small or big
	var new_power_state := "Small" if pwrup.tier == 1 else "Big"
	set_power_state(new_power_state) # Change the power state
	# Get the sprite frames for the damage animation
	var old_sprite = animated_sprite.sprite_frames
	var new_sprite := load("res://Sprites/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
	# Damage animation
	get_tree().paused = true
	for i in 4:
		animated_sprite.sprite_frames = old_sprite
		await get_tree().create_timer(0.07).timeout
		animated_sprite.sprite_frames = new_sprite
		await get_tree().create_timer(0.07).timeout
	get_tree().paused = false
	i_frames()
	return

# === That's what I needed! ===
func get_powerup(powerup := "") -> void:
	var new_powerup: PowerUps = get_node("PowerUpStates/" + powerup)
	if pwrup.tier > new_powerup.tier or pwrup == new_powerup:
		SaveManager.runtime_data["score"] = SaveManager.runtime_data.get("score", 0) + 100
		if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
			SaveManager.hud.update_labels()
		return
	await powerup_animation(powerup) # Wait for the animation
	set_power_state(powerup) # Set new powerup

# === Powerup transformation ===
func powerup_animation(powerup := "") -> void:
	# Get the sprite frames for the powerup animation
	var old_sprite = animated_sprite.sprite_frames
	var new_sprite := load("res://Sprites/Characters/" + character[character_index] + "/" + powerup + ".tres")
	get_tree().paused = true
	# Powerup animation
	for i in 4:
		animated_sprite.sprite_frames = old_sprite
		await get_tree().create_timer(0.07).timeout
		animated_sprite.sprite_frames = new_sprite
		await get_tree().create_timer(0.07).timeout
	get_tree().paused = false
	return

# === Change powerup state
func set_power_state(powerup: String) -> void:
	if powerup in PowerUps.power_ups:
		#pwrup.exit()
		pwrup = get_node("PowerUpStates/" + powerup)
		#pwrup.enter()
		
	else:
		push_error("Invalid powerup name! %s" % powerup)

# === i frames ===
func i_frames() -> void:
	can_take_damage = false
	for i in 16:
		animated_sprite.visible = false
		await get_tree().create_timer(0.05).timeout
		animated_sprite.visible = true
		await get_tree().create_timer(0.05).timeout
	can_take_damage = true
	return

# === P meter ===
func handle_p_meter():
	p_meter = clamp(p_meter, 0, p_meter_max)
	if p_meter > p_meter_max: p_meter = p_meter_max
	if p_meter >= p_meter_max and InputManager.B and InputManager.direction == velocity_direction and abs(velocity.x) >= run_speed: 
		extra_p_frames = 16.0
	elif extra_p_frames > 0 && is_on_floor(): extra_p_frames -= 1
	if abs(velocity.x) >= run_speed and InputManager.B and is_on_floor() and InputManager.direction == velocity_direction or not is_on_floor() and p_meter >= p_meter_max:
		p_meter += 1
	elif p_meter > 0 and extra_p_frames <= 0:
		p_meter -= 0.583

	return p_meter

# === Get slopes info ===
func get_slope_angle():
	return round(rad_to_deg(get_floor_angle()))
func get_slope_direction():
	return sign(get_floor_normal().x)

# === Set final acceleration (this function is currently only used for sliding) ===
func final_acc_speed():
	if get_slope_angle() == 0:
		return acc_speed
	elif get_slope_angle() <= 27 && state_machine.state.name == "Slide":
		return gentle_sliding_acc
	else:
		return steep_sliding_acc

# === Set max speeds ===
func final_max_speed():
	var is_going_uphill = get_slope_direction() == -1 and InputManager.direction == 1 or get_slope_direction() == 1 and InputManager.direction == -1

	# Uphill slope
	if get_slope_angle() > 0 && is_going_uphill:
			return uphill_max_run if InputManager.B else uphill_max_walk
	elif state_machine.state.name == "Slide":
		return sliding_max_speed if get_slope_angle() > 0 else 0.0
	else:
		if p_meter < p_meter_max:
			if InputManager.B: return run_speed + downhill_speed_modifier()
			else: return walk_speed + downhill_speed_modifier()
		else: return p_speed + downhill_speed_modifier()

# === Add speed downhill ===
func downhill_speed_modifier():
	if get_slope_angle() > 0 and get_slope_direction() == InputManager.direction:
		if get_slope_angle() <= 27: return added_gentle_slope_speed
		else: return added_steep_slope_speed
	else: return 0
