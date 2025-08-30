class_name Grabbable
extends Node

@export var grabbox: Area2D = null
@export var sprite: AnimatedSprite2D = null
@export var can_kick: bool
@export var can_kill: bool
var velocity: Vector2 = Vector2.ZERO
var holder: Player # Current object holder, multiple players can't hold the same obj
var plr: Player # Player reference for other shit
var default_z_index
var delay := 6 # Turn around animation delay
var delaying := false
var last_facing_direction := 1.0 # This is used for the turning around animation
var can_grab := true
var grab_delay := 0 # Frames in which you can't grab the object
var is_grabbed := false
var is_kicked := false


func _ready() -> void:
	default_z_index = owner.z_index # Get the default z index

func _process(_delta: float) -> void:

	# Wether the player body is inside the area
	var bodies = grabbox.get_overlapping_bodies()
	# === Get the player side ===
	# If we can kick the object determine from which side
	# is the object being kicked
	for body in bodies:
		if body.is_in_group("Player"):
			if can_kick and grab_delay == 0 and not is_kicked:
				owner.direction = sign(owner.global_position.x - body.global_position.x)

	# === Grabbing/Kicking logic ===
	# Get the object holder if we have none
	if holder == null:
		for body in bodies:
			if body.is_in_group("Player"):
				# If you're holding B hold it
				if body.input.is_action_pressed("B") and can_grab:
					holder = body
					holder.current_grabbed_obj = self
					is_grabbed = true
					break
				# Else Kick it (if you can)
				elif can_kick and grab_delay == 0 and not is_kicked:
					kick()
					break
	# Follow the holder if we have it
	elif holder.current_grabbed_obj == self:
		# Do it only if you're pressing B
		if holder in bodies and holder.input.is_action_pressed("B") and can_grab:
				owner.global_position.x = object_x_position(holder)
				owner.global_position.y = object_y_position(holder)
				holder.is_holding = true
				is_kicked = false
		# Else kick it
		else:
			# If you're not pressing down kick it
			if not holder.input.is_action_pressed("down"):
				SoundManager.play_sfx("Kick", owner.global_position)
				if can_kick: 
					is_kicked = true
					can_grab = false
				grab_delay = 15
				owner.direction = holder.facing_direction # Kick it in the direction the player's facing
				owner.z_index = default_z_index
				is_grabbed = false
				holder.is_holding = false
				holder.current_grabbed_obj = null
				holder = null
			else:
				grab_delay = 5
				owner.global_position.x = holder.global_position.x + 13 * holder.facing_direction
				owner.z_index = default_z_index
				is_grabbed = false
				holder.is_holding = false
				holder.current_grabbed_obj = null
				holder = null

	# Reference the players for other stuff
	var players = get_tree().get_nodes_in_group("Player")
	for p in players:
		plr = p
		# == Can grab logic ===
		# If we have grab delay or the object is kicked, don't let the player grab the obj
		# and decrease teh grab delay timer
		if is_kicked:
			can_grab = false
		if grab_delay > 0:
			can_grab = false
			grab_delay -= 1
		# Reset the flag
		elif not is_kicked:
			can_grab = true
	# Cap it to 0
	grab_delay = max(grab_delay, 0)

	bodies = grabbox.get_overlapping_bodies() # Do it twice for better checking


# Set the grabbable position (this also handles turning around)
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
		delaying= false
		owner.z_index = body.z_index - 1
		final_pos = body.global_position.x + 10 * body.facing_direction

	# Update
	last_facing_direction = body.facing_direction

	return final_pos

func object_y_position(body: Node):
	var final_y_pos = body.global_position.y - 17
	if not body.is_super:
		final_y_pos = body.global_position.y - 17
	else:
		final_y_pos = body.global_position.y - 19

	return final_y_pos

func kick():
	SoundManager.play_sfx("Kick", owner.global_position)
	is_kicked = true
	can_grab = false
	grab_delay = 15
