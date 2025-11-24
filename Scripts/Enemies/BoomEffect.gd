extends AnimatedSprite2D

var timer := 20

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	timer -= 1
	if timer <= 0:
		queue_free()
