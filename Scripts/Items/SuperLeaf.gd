extends PowerUpItem

var start_x
var timer := 0.0
var fall_speed := 28.0

func _ready() -> void:
	super._ready()
	start_x = global_position.x
	if from_block:
		velocity.y = -400.0

func _physics_process(delta: float) -> void:
	
	if from_block:
		if velocity.y == 0:
			from_block = false
		return

	$AnimatedSprite2D.scale.x = 1.0 * direction

	timer += delta
	velocity.x = start_x + 64 * (sin(timer * 4))
	velocity.y = sin(timer * 8.0) * 19.0 + 9.0

	#move_and_slide()
