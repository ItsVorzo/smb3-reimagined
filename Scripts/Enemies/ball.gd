extends EnemyClass

func _ready() -> void:
	init()

func _physics_process(delta: float) -> void:
	process(delta)
	if stomped or dead_from_obj:
		return
	move_and_slide()
