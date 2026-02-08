class_name Player
extends CharacterBody2D

# === Shortcuts ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var skid_sfx = $Skid
@onready var small_collision := $SmallCollision
@onready var big_collision := $BigCollision
@onready var hitbox := $HitBox
@onready var hitbox_small := $HitBox/SmallCollision
@onready var hitbox_big := $HitBox/BigCollision
@onready var tailbox := $TailAttackBox
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var bottom_pit := $"../CameraGroundLimit"
var input_device := -1
@export var player_id := 0
var character_index := 0
var character = ["Mario", "Luigi", "Toad", "Toadette"]
var goal_completed := false

# === Physics values ===
#region
var walk_speed = 0
var run_speed = 0
var p_speed = 0
var max_fly_speed = 0
var acc_speed = 0
var dec_speed = 0
var ice_dec_speed = 0
var skid_speed = 0
var hover_skid_speed = 0
var ice_skid_speed = 0
var end_level_walk = 0
var airship_cutscene_walk = 0
var added_gentle_slope_speed = 0
var added_steep_slope_speed = 0
var uphill_max_walk = 0
var uphill_max_run = 0
var gentle_sliding_acc = 0
var steep_sliding_acc = 0
var sliding_max_speed = 0

var jump_speeds = 0
var strong_bounce = 0
var weak_bounce = 0

var low_gravity = 0
var high_gravity = 0
const death_gravity = 420.0
#endregion

# === Other stuff ===
var animation_override := ""
var final_grav_speed: float
var direction_allow := true
var facing_direction := 1.0
var velocity_direction := 0.0
var pipe_enter_dir := Vector2.ZERO
var pipe_warping := false

var p_meter = 0.0
var p_meter_max = 70.0
var extra_p_frames = 16.0
var max_speed = 0.0
var kick_timer := 0
var shoot_timer := 0

# === States ===
@onready var state_machine: StateMachine = $States
@export var pwrup: PowerUps = null
var old_pwrup: PowerUps = null
var current_grabbed_obj: Grabbable
var crouching := false
var skidding = false
var hovering := false
var flying := false
var tail_attacking := false
var is_holding := false
var is_super := false
var is_dead := false
var has_star := false
var can_take_damage := true
var can_enter_pipe := true

# === Input shit ===
var input
var input_disabled := false

# === Udate the input devices ===
func update_input_device(player_num: int):
	var device
	if not PlayerManager.get_unjoined_devices().is_empty():
		device = PlayerManager.get_unjoined_devices()[0]
		PlayerManager.join(device)
	else:
		device = PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)

# === Apply unique physics ===
func apply_physics(i:int) -> void:
	walk_speed = PhysicsVal.walk_speed[i]
	run_speed = PhysicsVal.run_speed[i]
	p_speed = PhysicsVal.p_speed[i]
	max_fly_speed = PhysicsVal.max_fly_speed
	acc_speed = PhysicsVal.acc_speed[i]
	dec_speed = PhysicsVal.dec_speed[i]
	ice_dec_speed = PhysicsVal.ice_dec_speed[i]
	skid_speed = PhysicsVal.skid_speed[i]
	hover_skid_speed = PhysicsVal.hover_skid_speed
	ice_skid_speed = PhysicsVal.ice_skid_speed[i]
	end_level_walk = PhysicsVal.end_level_walk
	airship_cutscene_walk = PhysicsVal.airship_cutscene_walk
	added_gentle_slope_speed = PhysicsVal.added_gentle_slope_speed[i]
	added_steep_slope_speed = PhysicsVal.added_steep_slope_speed[i]
	uphill_max_walk = PhysicsVal.uphill_max_walk[i]
	uphill_max_run = PhysicsVal.uphill_max_run[i]
	gentle_sliding_acc = PhysicsVal.gentle_sliding_acc[i]
	steep_sliding_acc = PhysicsVal.steep_sliding_acc[i]
	sliding_max_speed = PhysicsVal.sliding_max_speed

	jump_speeds = PhysicsVal.jump_speeds[i]
	strong_bounce = PhysicsVal.strong_bounce[i]
	weak_bounce = PhysicsVal.weak_bounce[i]

	low_gravity = PhysicsVal.low_gravity[i]
	high_gravity = PhysicsVal.high_gravity[i]

func _ready() -> void:
	# Disconnect controller
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	# Character indexes will be handles differently
	SaveManager.start_runtime_from_save(0) # 1st step to getting the character index
	character_index = player_id # 2nd step

	# Load saved powerup state from save file
	var saved_powerup = SaveManager.runtime_data.get("powerup_state", "Small")
	set_power_state(saved_powerup)
	
	# Load the correct sprites
	animated_sprite.sprite_frames = load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
	
	apply_physics(character_index) # Apply unique physics (will be a toggle in the future)
	add_to_group("Player")

func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		PlayerManager.leave_device(device)

# === Player logic ===
func _physics_process(delta: float) -> void:
	# Remove unused players
	var device = PlayerManager.get_player_device(player_id)
	if device == null:
		PlayerManager.leave(device)
		queue_free()
		return

	# Update input devices for local multiplayer
	if PlayerManager.player_data and not input_disabled:
		update_input_device(player_id)

	# If you're dead or no input device is detected return
	if is_dead or goal_completed or not input:
		move_and_slide()
		return

	handle_powerups(delta)

	# Bump
	if is_on_ceiling():
		SoundManager.play_sfx("Hit", global_position)

	# === Set variables ===
	max_speed = final_max_speed()
	p_meter = handle_p_meter()
	skidding = input_direction() != 0 and velocity_direction != 0 and input_direction() != velocity_direction and !crouching
	animated_sprite.scale.x = sprite_direction()
	velocity_direction = sign(velocity.x)
	if skidding and is_on_floor():
		if skid_sfx.is_playing() == false:
			skid_sfx.play()
	else:
		skid_sfx.stop()
	# Reset skidding
	if input_direction() == 0:
		skidding = false

	# Jumping
	if input.is_action_just_pressed("A") and is_on_floor():
		var final_jump_speed = floor(abs(velocity.x)/60)
		velocity.y = jump_speeds[final_jump_speed]
		SoundManager.play_sfx("Jump", global_position)

	if current_grabbed_obj == null:
		is_holding = false

	# Timers
	if shoot_timer > 0:
		if is_on_floor():
			if animation_override != "shoot":
				animation_override = "shoot"
		else:
			if animation_override != "swim":
				animation_override = "swim"
		shoot_timer -= 1
	elif kick_timer > 0:
		if animation_override != "kick" or animation_override != "tail_attack":
			animation_override = "kick"
		kick_timer -= 1

	# Player dies when you fall in a pit
	if not is_dead and is_instance_valid(bottom_pit):
		if global_position.y > bottom_pit.global_position.y + 54: die()
		SaveManager.runtime_data["powerup_state"] = "Small"

	move_and_slide()

func apply_gravity(delta: float) -> void:
	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < -120 and input.is_action_pressed("A"): final_grav_speed = low_gravity
		else: final_grav_speed = high_gravity
		velocity.y += final_grav_speed * delta
		velocity.y = min(velocity.y, 258.75)

# === Get the input direction ===
func input_direction() -> int:
	if input:
		return input.get_axis("left", "right")
	else:
		return 0

# === Set the sprite x scale ===
func sprite_direction():
	if direction_allow and input_direction() != 0:
		facing_direction = input_direction()
	return facing_direction

# === Bounce on koopalings ===
func bounce_on_enemy() -> void:
	if state_machine.state.name != "Normal":
		state_machine.change_state("Normal")
	if input.is_action_pressed("A"):
		velocity.y = -240.0
	else:
		velocity.y = -180.0

# === That's what I needed! ===
func get_powerup(powerup := "") -> void:
	var new_powerup: PowerUps = get_node("PowerUpStates/" + powerup)
	SoundManager.play_sfx("PowerUp", global_position)
	if pwrup.tier > new_powerup.tier or pwrup == new_powerup:
		SaveManager.add_score(100)
		return
	transform_animation(new_powerup.animation_type, new_powerup.name)
	set_power_state(powerup) # Set new powerup
	return

# === Change powerup state ===
func set_power_state(powerup: String) -> void:
	if powerup in PowerUps.power_ups:
		old_pwrup = pwrup
		pwrup.exit()
		pwrup = get_node("PowerUpStates/" + powerup)
		pwrup.enter()
	else:
		push_error("Invalid powerup name! %s" % powerup)

# === Powerup logic ===
func handle_powerups(delta: float):
	pwrup.physics_update(delta)
	animated_sprite.sprite_frames = load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
	# Change collision shapes
	is_super = pwrup.tier >= 1
	if pipe_warping: return
	if not is_super or crouching:
		small_collision.disabled = false
		hitbox_small.disabled = false
		big_collision.disabled = true
		hitbox_big.disabled = true
	else:
		small_collision.disabled = true
		hitbox_small.disabled = true
		big_collision.disabled = false
		hitbox_big.disabled = false

# === DIE! ===
func die() -> void:
	if state_machine.state.name == "Die":
		return
	state_machine.change_state("Die")

# === Ouch :( ===
func damage() -> void:
	if not can_take_damage:
		return
	# If you're small DIE
	if pwrup.tier == 0:
		return die()

	SoundManager.play_sfx("Pipe", global_position)
	# Become either small or big
	var new_power_state := "Small" if pwrup.tier == 1 else "Big"
	set_power_state(new_power_state) # Change the power state
	var animation_type = 0 if old_pwrup.animation_type != 2 else 2
	transform_animation(animation_type)
	return

# === It's the super mario brother ===
# animation_type = 0, damage animation
# animation_type = 1, normal powerup animation
# animation_type = 2, poof powerup animation
func transform_animation(animation_type := 1, powerup := "") -> void:
	# Damage
	if animation_type == 0:
		var old_sprite = animated_sprite.sprite_frames
		var new_sprite := load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
		# Flashing damage animation
		if pwrup.tier == 0:
			get_tree().paused = true
			animated_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
			animated_sprite.sprite_frames = new_sprite
			animated_sprite.animation = "powerdown"
			i_frames()
			await small_big_transition()
			get_tree().paused = false
			animated_sprite.process_mode = Node.PROCESS_MODE_INHERIT
		# Flashing powerdown animation
		else:
			i_frames()
			get_tree().paused = true
			for i in 4:
				animated_sprite.sprite_frames = old_sprite
				await get_tree().create_timer(4.0 / 60.0988).timeout
				animated_sprite.sprite_frames = new_sprite
				await get_tree().create_timer(4.0 / 60.0988).timeout
			get_tree().paused = false

	# Powerup Grow/Flash
	elif animation_type == 1:
		var old_sprite = animated_sprite.sprite_frames
		var new_sprite := load("res://SpriteFrames/Characters/" + character[character_index] + "/" + powerup + ".tres")
		# Growing powerup animation
		if powerup == "Big":
			get_tree().paused = true
			animated_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
			animated_sprite.sprite_frames = new_sprite
			animated_sprite.animation = "powerup"
			await small_big_transition()
			get_tree().paused = false
			animated_sprite.process_mode = Node.PROCESS_MODE_INHERIT
		# Flashing powerup animation
		else:
			get_tree().paused = true
			for i in 4:
				animated_sprite.sprite_frames = old_sprite
				await get_tree().create_timer(4.0 / 60.0988).timeout
				animated_sprite.sprite_frames = new_sprite
				await get_tree().create_timer(4.0 / 60.0988).timeout
			get_tree().paused = false

	# Poof animation
	elif animation_type == 2:
		get_tree().paused = true
		var smoke_scene = load("res://Scenes/Effects/SmokeEffect.tscn").instantiate()
		smoke_scene.process_mode = Node.PROCESS_MODE_ALWAYS
		animated_sprite.hide()
		add_child(smoke_scene)
		smoke_scene.global_position = Vector2(global_position.x, global_position.y - 12)
		await smoke_scene.animation_finished
		smoke_scene.process_mode = Node.PROCESS_MODE_INHERIT
		animated_sprite.show()
		if old_pwrup.tier > pwrup.tier:
			i_frames()
		get_tree().paused = false

# === Transition between small and big mario ===
func small_big_transition() -> void:
	for i in 3:
		animated_sprite.frame = 1
		await get_tree().create_timer(4.0 / 60.0988).timeout
		animated_sprite.frame = 0
		await get_tree().create_timer(4.0 / 60.0988).timeout
	for i in 3:
		animated_sprite.frame = 1
		await get_tree().create_timer(4.0 / 60.0988).timeout
		animated_sprite.frame = 2
		await get_tree().create_timer(4.0 / 60.0988).timeout
	return

# === i frames ===
func i_frames() -> void:
	can_take_damage = false
	for i in 28:
		animated_sprite.hide()
		await get_tree().create_timer(2.0 / 60.0988).timeout
		animated_sprite.show()
		await get_tree().create_timer(2.0 / 60.0988).timeout
	can_take_damage = true
	return

# === Pipe animation ===
func enter_pipe(pipe: PipeArea) -> void:
	pipe_warping = true
	direction_allow = false
	z_index = -1
	pipe_enter_dir = pipe.get_vector(pipe.entrance_direction)
	PipeArea.exiting_pipe_id = pipe.pipe_id
	if pipe_enter_dir.x != 0:
		global_position.y -= 2 # Slight elevation
	state_machine.change_state("Pipe")
	if pipe_enter_dir.x != 0:
		animated_sprite.play("walk", 2)
	if pipe_enter_dir.y != 0:
		animated_sprite.play("front_facing")
	await get_tree().create_timer(0.65).timeout
	# Save powerup state
	SaveManager.runtime_data["powerup_state"] = pwrup.name
	SaveManager.commit_runtime_to_save(0)
	hide()

# Set the player when you're about to exit the pipe
func go_to_exit_pipe(pipe: PipeArea) -> void:
	pipe_warping = true
	direction_allow = false
	z_index = -1
	state_machine.change_state("None") # In this state you aren't able to do ANYTHING
	pipe_enter_dir = Vector2.ZERO
	global_position = pipe.global_position
	# Set the player's position offsets
	if pipe.entrance_direction == 1:
		global_position.y -= 18
	if pipe.entrance_direction == 2:
		global_position.y += 34
	if pipe.get_vector(pipe.entrance_direction).x != 0:
		global_position.y += 15
		global_position.x += 27 * pipe.get_vector(pipe.entrance_direction).x
	reset_physics_interpolation() # i'm not ENTIRELY sure about what this does

# Pipe exit animation
func exit_pipe(pipe: PipeArea) -> void:
	show()
	pipe_enter_dir = -pipe.get_vector(pipe.entrance_direction)
	SoundManager.play_sfx("Pipe", global_position)
	state_machine.change_state("Pipe")
	if pipe_enter_dir.x != 0:
		animated_sprite.play("walk", 2)
	if pipe_enter_dir.y != 0:
		animated_sprite.play("front_facing")
	if pipe_enter_dir.y == 1:
		state_machine.change_state("None")
		velocity.y = 258.75
	await get_tree().create_timer(0.65 if pipe_enter_dir.y != 1 else 0.2, false).timeout
	pipe_warping = false
	direction_allow = true
	z_index = 3
	state_machine.change_state("Normal")
	pipe_enter_dir = Vector2.ZERO

# === P meter ===
func handle_p_meter():
	p_meter = clamp(p_meter, 0, p_meter_max)
	if p_meter > p_meter_max: p_meter = p_meter_max
	# Reset the extra frames in which you have a full p meter
	if p_meter >= p_meter_max and input.is_action_pressed("B") and input_direction() == velocity_direction and abs(velocity.x) >= run_speed: 
		extra_p_frames = 16.0
	elif extra_p_frames > 0 and is_on_floor(): extra_p_frames -= 1
	var ground_conditions = state_machine.state.name == "Normal" and abs(velocity.x) >= run_speed and input.is_action_pressed("B") and is_on_floor() and input_direction() == velocity_direction
	var air_conditions = not is_on_floor() and p_meter >= p_meter_max
	if (ground_conditions) or (air_conditions):
		p_meter += 1
	elif p_meter > 0 and extra_p_frames <= 0:
		p_meter -= 0.583

	# Store it globally
	GameManager.p_meter.clear()
	for player in get_tree().get_nodes_in_group("Player"):
		GameManager.p_meter.append(player.p_meter)

	return p_meter

# === Get slopes info ===
func get_slope_angle():
	return round(rad_to_deg(get_floor_angle()))
func get_slope_direction():
	return sign(get_floor_normal().x)

# === Set final acceleration (this function is currently only used for sliding) ===
func final_acc_speed():
	if flying:
		if abs(velocity.x) > max_fly_speed:
			return 0.9375 # This counts as deceleration but i think it's the only exception
		else:
			return acc_speed
	else:
		if get_slope_angle() == 0 or not is_on_floor():
			return acc_speed
		elif get_slope_angle() <= 27 and state_machine.state.name == "Slide":
			return gentle_sliding_acc
		else:
			return steep_sliding_acc

func final_skid_speed():
	if not hovering or not flying:
		return skid_speed
	else:
		return hover_skid_speed

func final_dec_speed():
	if hovering:
		return 3.75
	else:
		return dec_speed

# === Set max speeds ===
func final_max_speed():
	var is_going_uphill = get_slope_direction() == -1 and input_direction() == 1 or get_slope_direction() == 1 and input_direction() == -1

	if not flying:
	# Uphill slope
		if get_slope_angle() > 0 and is_going_uphill:
				return uphill_max_run if input.is_action_pressed("B") else uphill_max_walk
		elif state_machine.state.name == "Slide":
			return sliding_max_speed if get_slope_angle() > 0 else 0.0
		else:
			if p_meter < p_meter_max:
				if input.is_action_pressed("B"): return run_speed + downhill_speed_modifier()
				else: return walk_speed + downhill_speed_modifier()
			else: return p_speed + downhill_speed_modifier()
	else:
		return max_fly_speed

# === Add speed downhill ===
func downhill_speed_modifier():
	if get_slope_angle() > 0 and get_slope_direction() == input_direction():
		if get_slope_angle() <= 27: return added_gentle_slope_speed
		else: return added_steep_slope_speed
	else: return 0
