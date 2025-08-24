extends PowerUpItem

var gravity := 500.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity
	move_and_slide()
