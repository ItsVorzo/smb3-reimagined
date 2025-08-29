class_name Grabbable
extends Node

@export var grabbox: Area2D = null
@export var sprite: AnimatedSprite2D = null
var velocity: Vector2 = Vector2.ZERO
var plr: Player
var default_z_index
var delay := 10
var delaying := false
var last_facing_direction := 1 # This is used for the turning around animation
var is_grabbed := false
var is_kicked := false


func _ready() -> void:
	default_z_index = owner.z_index # Get the default z index

func _process(_delta: float) -> void:
	is_kicked = not is_grabbed # This is going to be changed

	var bodies = grabbox.get_overlapping_bodies() # Wether the player body is inside the area
	for body in bodies:
		if body.is_in_group("Player"):

			is_grabbed = body.input.is_action_pressed("B")

			if is_grabbed:
				owner.global_position.x = object_position(body)
				owner.global_position.y = body.global_position.y - 16
				body.is_holding = true
				is_kicked = false
			else:
				body.is_holding = false
				is_kicked = true

func object_position(body: Node):
	var final_pos = body.global_position.x + 10 * body.facing_direction
	owner.z_index = default_z_index

	# Turn around
	if body.facing_direction != last_facing_direction and delay == 10:
		delay = 0
		delaying = true
	if delaying:
		if delay < 10:
			delay += 1
		owner.z_index = body.z_index + 1
		final_pos = body.global_position.x
	if delay == 10:
		delaying= false
		owner.z_index = default_z_index
		final_pos = body.global_position.x + 10 * body.facing_direction

	last_facing_direction = body.facing_direction

	return final_pos
