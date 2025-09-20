extends PowerUpItem

var xspd = 50.0
var gravity := 500.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not from_block:
		z_index = default_z_index
		collision.disabled = false
		velocity.x = xspd * direction
		if not is_on_floor(): velocity.y += gravity * delta

	move_and_slide()

	if is_on_wall():
		direction *= -1

func from_block_anim() -> void:
	default_anim()
