extends PowerUpItem

@onready var sprite := $Sprite2D
@onready var collision := $Collision
var xspd = 50.0
var gravity := 500.0

var target_y

func _ready() -> void:
	target_y = self.global_position.y - 10
	pick_up_area.body_entered.connect(body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not from_block:
		z_index = default_z_index
		collision.disabled = false
		velocity.x = xspd * direction
		if not is_on_floor(): velocity.y += gravity * delta
	else:
		collision.disabled = true
		if global_position.y >= target_y:
			global_position.y -= 0.4
		else:
			from_block = false

	move_and_slide()

	if is_on_wall():
		direction *= -1
