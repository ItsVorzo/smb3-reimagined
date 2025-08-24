class_name PowerUpItem
extends CharacterBody2D

@export var pick_up_area: Area2D = null
@export var powerup := ""

var direction := 1
var from_block := false

func _ready() -> void:
	if from_block:
		await get_tree().create_timer(0.5).timeout 
		pick_up_area.body_entered.connect(body_entered)
	else:
		pick_up_area.body_entered.connect(body_entered)

func body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.get_powerup(powerup)
		queue_free()
