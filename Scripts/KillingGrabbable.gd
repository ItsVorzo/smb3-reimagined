class_name KillingGrabbable
extends Node

@export var hurtbox: Area2D = null
@export var grab: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurtbox.body_entered.connect(damage)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func damage(body: Node) -> void:
	if body.is_in_group("Enemies"):
		if grab.is_grabbed:
			kill(body)
		else:
			kill(body)

func kill(body: Node) -> void:
	body.dead_from_obj = true
	body.velocity.y = -100.0
	body.xspd = owner.xspd
