class_name PowerUpItem
extends CharacterBody2D

@export var pick_up_area: Area2D = null
@export var powerup := ""

var direction := 1
var from_block := false

func _ready() -> void:
	if pick_up_area: 
		pick_up_area.body_entered.connect(body_entered)

func body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.powerup_animation(powerup)
		queue_free()
