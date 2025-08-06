extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var velocity := Vector2.ZERO
var gravity := 900.0
var rotation_speed := 0.0

func launch(direction_index: int):
	# Assign initial velocity based on which chunk this is
	match direction_index:
		0: velocity = Vector2(-80, -200); rotation_speed = -6.0
		1: velocity = Vector2(80, -220);  rotation_speed = 6.0
		2: velocity = Vector2(-100, -160); rotation_speed = -4.0
		3: velocity = Vector2(100, -180);  rotation_speed = 4.0

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta

	# Auto-destroy after falling for 0.5–1s
	if position.y > 1000: # or use a timer if preferred
		queue_free()
