class_name Grabbable
extends Node

# === Grabbable info ===
@export var grabbox: Area2D = null
@export var sprite: AnimatedSprite2D = null
@export var can_kick: bool

# === General shit ===
var velocity: Vector2 = Vector2.ZERO
var holder: Player # Current object holder, multiple players can't hold the same obj
var plr: Player # Player reference for other shit
var default_z_index # The z index set by default
var delay := 6 # Turn around animation delay
var delaying := false 
var last_facing_direction := 1.0 # This is used for the turning around animation
var can_grab := true
var grab_delay := 0 # Frames in which you can't grab the object
var is_grabbed := false
var is_kicked := false
var is_just_released := false

@warning_ignore("unused_signal") signal on_kicked

func _ready() -> void:
	grabbox.body_entered.connect(grab)
	default_z_index = owner.z_index # Get the default z index

func _physics_process(_delta: float) -> void:

	if not grabbox.monitoring:
		return

	# === Grabbing/Kicking logic ===
	# Kick the shell if the player is inside
	for body in grabbox.get_overlapping_bodies():
		if body.is_in_group("Player") and not holder and not is_kicked and grab_delay == 0:
			kick(body)

	# Follow the holder if we have it
	if holder and holder.current_grabbed_obj == self:
		# Do it only if you're pressing B
		if holder and holder.input.is_action_pressed("B") and can_grab:
				owner.global_position.x = object_x_position(holder)
				owner.global_position.y = object_y_position(holder)
				holder.is_holding = true
				is_kicked = false
		else:
			# If you're not pressing down kick it
			if not holder.input.is_action_pressed("down"):
				SoundManager.play_sfx("Kick", owner.global_position)
				kick(holder)
				holder.is_holding = false
				holder.current_grabbed_obj = null
				holder = null
			# Else carefully place it down
			else:
				release()

	# Reference EACH player for other stuff
	for p in get_tree().get_nodes_in_group("Player"):
		plr = p

		# Some state switching
		if is_kicked:
			can_grab = false
		if grab_delay > 0:
			can_grab = false
		# Reset the flag
		elif not is_kicked:
			can_grab = true

	if owner.is_on_floor():
		is_just_released = false

	# Decrease the timer
	if grab_delay > 0: grab_delay -= 1

# Grab them objects
func grab(body: Node) -> void:
	if holder == null:
		if body.is_in_group("Player"):
			# If you're holding B hold it
			if body.input.is_action_pressed("B") and can_grab and body.current_grabbed_obj == null:
				holder = body
				if holder.current_grabbed_obj == null: 
					holder.current_grabbed_obj = self
				is_grabbed = true
				last_facing_direction = holder.facing_direction
			# Else Kick it (if you can)
			elif can_kick and grab_delay == 0 and not is_kicked:
				kick(body)

# 1, 2, 3, kick it
func kick(body):
	SoundManager.play_sfx("Kick", owner.global_position)
	grab_delay = 15
	is_kicked = true
	can_grab = false
	if holder == null:
		owner.direction = sign(owner.global_position.x - body.global_position.x)
	else:
		holder.kick_timer = 10
		is_grabbed = false
		owner.direction = holder.facing_direction
	on_kicked.emit()

# Place it down
func release() -> void:
	grab_delay = 5
	is_just_released = true
	owner.global_position.x = holder.global_position.x + 13 * holder.facing_direction
	owner.z_index = default_z_index
	is_grabbed = false
	holder.is_holding = false
	holder.current_grabbed_obj = null
	holder = null

# Set the obj x position (this also handles turning around)
func object_x_position(body: Node):
	var final_pos = body.global_position.x + 10 * body.facing_direction # Determine the object position
	owner.z_index = body.z_index - 1

	# Turn around
	if body.facing_direction != last_facing_direction and delay == 6:
		delay = 0
		delaying = true
	if delaying:
		if delay < 6:
			delay += 1
		owner.z_index = body.z_index + 1
		if delay <= 3: final_pos = body.global_position.x + 4 * last_facing_direction
		elif delay <= 6: final_pos = body.global_position.x + 4 * body.facing_direction
	if delay == 6:
		delaying = false
		owner.z_index = body.z_index - 1
		final_pos = body.global_position.x + 10 * body.facing_direction

	# Update
	last_facing_direction = body.facing_direction

	return final_pos

# Obj y position
func object_y_position(body: Node):
	var final_y_pos = body.global_position.y - 9
	if not body.is_super:
		final_y_pos = body.global_position.y - 9
	else:
		final_y_pos = body.global_position.y - 11

	return final_y_pos
