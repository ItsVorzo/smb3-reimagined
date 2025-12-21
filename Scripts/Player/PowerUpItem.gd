class_name PowerUpItem
extends CharacterBody2D

@export var pick_up_area: Area2D = null
@export var collision: CollisionShape2D = null
@export var powerup := ""

var direction := 1
var from_block := false
var default_z_index := 0
var target_y

func _ready() -> void:
	if from_block:
		target_y = self.global_position.y - 10
	pick_up_area.body_entered.connect(body_entered)
	add_to_group("Items")

func _physics_process(_delta: float) -> void:
	if from_block:
		from_block_anim()
	else:
		return

func body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.get_powerup(powerup)
		queue_free()

func from_block_anim() -> void:
	pass

func default_anim() ->void:
	collision.disabled = true
	if global_position.y >= target_y:
		global_position.y -= 0.2
	else:
		from_block = false
