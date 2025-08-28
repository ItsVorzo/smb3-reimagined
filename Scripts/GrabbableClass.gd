class_name Grabbable
extends Node

@export var grabbox: Area2D = null
var velocity: Vector2 = Vector2.ZERO
var plr: Player = null
var is_grabbed := false
var is_kicked := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var bodies = grabbox.get_overlapping_bodies()
	var grabbed_this_frame = false

	for body in bodies:
		if body.is_in_group("Player"):
			if body.input.is_action_pressed("B"):
				is_grabbed = true
				plr = body
				grabbed_this_frame = true
				owner.global_position.x = body.global_position.x + 10 * body.facing_direction
				owner.global_position.y = body.global_position.y - 16
				is_kicked = false
				break

	if not grabbed_this_frame:
		is_grabbed = false
		plr = null
		is_kicked = true
