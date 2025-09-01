class_name PowerUpItem
extends CharacterBody2D

@export var pick_up_area: Area2D = null
@export var powerup := ""

var direction := 1
var from_block := false
var default_z_index := 0

func body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.get_powerup(powerup)
		queue_free()
