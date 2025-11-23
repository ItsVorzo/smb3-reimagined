extends CharacterBody2D

@export_enum("Red", "Green") var color = "Red"
@onready var area2d = $Area2D
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("Spin" + str(color))
	area2d.body_entered.connect(kill)

func kill(body: Node):
	if body.is_in_group("Player"):
		body.damage()

func _physics_process(delta: float) -> void:
	if not GameManager.is_on_screen(global_position):
		queue_free()
	move_and_slide()
