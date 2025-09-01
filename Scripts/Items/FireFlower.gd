extends PowerUpItem

@onready var collision = $Collision
var gravity := 500.0
var target_y

func _ready() -> void:
	target_y = self.global_position.y - 10
	pick_up_area.body_entered.connect(body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if from_block:
		collision.disabled = true
		if global_position.y >= target_y:
			global_position.y -= 0.4
		else:
			from_block = false
	else:
		z_index = default_z_index
		collision.disabled = false
		if not is_on_floor():
			velocity.y += gravity * delta
	move_and_slide()
