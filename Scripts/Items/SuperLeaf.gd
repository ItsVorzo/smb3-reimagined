extends PowerUpItem

var start_x
var max_x
var timer = 0.0

func _ready() -> void:
	super._ready()
	start_x = global_position.x
	max_x = start_x + 16
	if from_block:
		velocity.y = -400.0

func _physics_process(delta: float) -> void:
	
	if from_block:
		if velocity.y == 0:
			from_block = false
	else:
		timer += delta
		global_position.x = start_x + 16 * (sin(timer * 4) + 1.0)
	move_and_slide()
