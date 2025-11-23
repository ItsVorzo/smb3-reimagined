extends EnemyClass

func _ready() -> void:
	init()

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()
	if stomped:
		sprite.play("squish")
	move_and_slide()
	flip_direction()
