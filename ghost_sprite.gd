extends Node2D

@export var fade_time := 0.3
@onready var sprite := $"Disc/Area2D/Sprite2D"

var timer := 0.0

func _ready():
	# Start fully visible
	sprite.modulate.a = 1.0

func _process(delta):
	timer += delta
	var t = timer / fade_time

	# Fade out
	sprite.modulate.a = 1.0 - t

	# Scale or rotate fade effect (optional)
	# scale = Vector2.ONE * (1.0 + t * 0.2)

	if t >= 1.0:
		queue_free()
