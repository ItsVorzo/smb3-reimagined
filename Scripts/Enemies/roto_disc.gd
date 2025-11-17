extends EnemyClass

func _ready() -> void:
	init()

func _physics_process(delta: float) -> void:
	remove_from_group("Enemies")
	process(delta)
	if stomped:
		move_and_slide()
