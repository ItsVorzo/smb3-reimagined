class_name Player
extends CharacterBody2D

# === Shortcuts ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var skid_sfx = $Skid
@onready var normal_collision_shape := $CollisionShape2D
@onready var super_collision_shape := $SuperCollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var bottom_pit := $"../CameraGroundLimit"
var input_device := -1
@export var player_id := 0
var character_index := 0
var character = ["Mario", "Luigi", "Toad", "Toadette"]

# === Physics values ===
#region
var walk_speed = 0
var run_speed = 0
var p_speed = 0
var acc_speed = 0
var frc_speed = 0
var ice_frc_speed = 0
var skid_speed = 0
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
var current_grabbed_obj: Grabbable
var current_powerup: int = 0
var jump_buffer_timer = 0.12
var coyote_timer = 0.12
var crouching := false
var skidding = false
var is_super := false
var can_take_damage := true
var is_dead := false
var is_holding := false

# === Input shit ===
var input

# === Udate the input devices ===
func update_input_device(player_num: int):
	var device
	if not PlayerManager.get_unjoined_devices().is_empty():
		device = PlayerManager.get_unjoined_devices()[0]
		PlayerManager.join(device)
	else:
		device = PlayerManager.get_player_device(player_num)
	input = DeviceInput.new(device)

# === Update the character index ===
func char_idx() -> int:
	return player_id

func player_instance_exists(id: int) -> bool:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.player_id == id:
			return true
	return false

# === Apply unique physics ===
func apply_physics(i:int) -> void:
	walk_speed = PhysicsVal.walk_speed[i]
	run_speed = PhysicsVal.run_speed[i]
	p_speed = PhysicsVal.p_speed[i]
	acc_speed = PhysicsVal.acc_speed[i]
	frc_speed = PhysicsVal.frc_speed[i]
	ice_frc_speed = PhysicsVal.ice_frc_speed[i]
	skid_speed = PhysicsVal.skid_speed[i]
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

	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	InputManager.player = self 
	SaveManager.start_runtime_from_save(0) # 1st step to getting the character index
	character_index = char_idx() # Get the current character index
	animated_sprite.sprite_frames = load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
	apply_physics(character_index) # Apply unique physics (will be a toggle in the future)
	add_to_group("Player") # Add to the correct group

func _on_joy_connection_changed(device: int, connected: bool):
	if not connected:
		PlayerManager.leave_device(device)

# === Logic ===
func _process(delta):

	# === Remove unused players ===
	var device = PlayerManager.get_player_device(player_id)
	if device == null:
		PlayerManager.leave(device)
		queue_free()
		return

	# === Update input devices for local multiplayer ===
	if PlayerManager.player_data:
		update_input_device(player_id) 

	# === Set variables ===
	max_speed = final_max_speed()
	p_meter = handle_p_meter()
	skidding = input_direction() != 0 and velocity_direction != 0 and input_direction() != velocity_direction and is_on_floor() and !crouching
	if skidding:
		if skid_sfx.is_playing() == false:
			skid_sfx.play()
	else:
		skid_sfx.stop()
	animated_sprite.scale.x = sprite_direction()
	velocity_direction = sign(velocity.x)

	# === Timers ===
	if not is_on_floor():
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time

	if input.is_action_just_pressed("A"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= 1

# === Physics ===
func _physics_process(delta: float) -> void:

	if pwrup.tier >= 1:
		is_super = true
	else:
		is_super = false
	#is_super = pwrup.tier >= 1
	normal_collision_shape.disabled = is_super
	super_collision_shape.disabled = not is_super
	print(is_super)

	# If you're dead or no input device is detected return
	if is_dead or not input:
		return

	# Reset skidding
	if input_direction() == 0:
		skidding = false

	# === Gravity and Jumping ===
	if not is_on_floor():
		if velocity.y < -120 and input.is_action_pressed("A"): final_grav_speed = low_gravity
		else: final_grav_speed = high_gravity
		velocity.y += final_grav_speed * delta
		velocity.y = min(velocity.y, 258.75)
	# Jumping
	if input.is_action_just_pressed("A") and is_on_floor():
		var final_jump_speed = floor(abs(velocity.x)/60)
		velocity.y = jump_speeds[final_jump_speed]
		SoundManager.play_sfx("JumpSmall", global_position)

	# Player dies when you fall in a pitS
	if !is_dead && is_instance_valid(bottom_pit):
		if global_position.y > bottom_pit.global_position.y + 54: die()

	move_and_slide()

# === Get the input direction ===
func input_direction() -> int:
	if input:
		return input.get_axis("left", "right")
	else:
		return 0

# === Set the sprite x scale ===
func sprite_direction():
	if direction_allow && input_direction() != 0:
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

	SoundManager.play_sfx("Pipe", global_position)
	# Become either small or big
	var new_power_state := "Small" if pwrup.tier == 1 else "Big"
	set_power_state(new_power_state) # Change the power state
	# Get the sprite frames for the damage animation
	var old_sprite = animated_sprite.sprite_frames
	var new_sprite := load("res://SpriteFrames/Characters/" + character[character_index] + "/" + pwrup.name + ".tres")
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
		SoundManager.play_sfx("PowerUp", global_position)
		return
	await powerup_animation(powerup) # Wait for the animation
	set_power_state(powerup) # Set new powerup

# === Powerup transformation ===
func powerup_animation(powerup := "") -> void:
	SoundManager.play_sfx("PowerUp", global_position)
	# Get the sprite frames for the powerup animation
	var old_sprite = animated_sprite.sprite_frames
	var new_sprite := load("res://SpriteFrames/Characters/" + character[character_index] + "/" + powerup + ".tres")
	get_tree().paused = true
	# Powerup animation
	for i in 4:
		animated_sprite.sprite_frames = old_sprite
		await get_tree().create_timer(0.07).timeout
		animated_sprite.sprite_frames = new_sprite
		await get_tree().create_timer(0.07).timeout
	get_tree().paused = false
	return

# === Change powerup state ===
func set_power_state(powerup: String) -> void:
	if powerup in PowerUps.power_ups:
		pwrup.exit()
		pwrup = get_node("PowerUpStates/" + powerup)
		pwrup.enter()
	else:
		push_error("Invalid powerup name! %s" % powerup)

# === i frames ===
func i_frames() -> void:
	for i in 16:
		can_take_damage = false
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
	if p_meter >= p_meter_max and input.is_action_pressed("B") and input_direction() == velocity_direction and abs(velocity.x) >= run_speed: 
		extra_p_frames = 16.0
	elif extra_p_frames > 0 && is_on_floor(): extra_p_frames -= 1
	if state_machine.state.name == "Normal" and abs(velocity.x) >= run_speed and input.is_action_pressed("B") and is_on_floor() and input_direction() == velocity_direction or not is_on_floor() and p_meter >= p_meter_max:
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
	var is_going_uphill = get_slope_direction() == -1 and input_direction() == 1 or get_slope_direction() == 1 and input_direction() == -1

	# Uphill slope
	if get_slope_angle() > 0 && is_going_uphill:
			return uphill_max_run if input.is_action_pressed("B") else uphill_max_walk
	elif state_machine.state.name == "Slide":
		return sliding_max_speed if get_slope_angle() > 0 else 0.0
	else:
		if p_meter < p_meter_max:
			if input.is_action_pressed("B"): return run_speed + downhill_speed_modifier()
			else: return walk_speed + downhill_speed_modifier()
		else: return p_speed + downhill_speed_modifier()

# === Add speed downhill ===
func downhill_speed_modifier():
	if get_slope_angle() > 0 and get_slope_direction() == input_direction():
		if get_slope_angle() <= 27: return added_gentle_slope_speed
		else: return added_steep_slope_speed
	else: return 0
