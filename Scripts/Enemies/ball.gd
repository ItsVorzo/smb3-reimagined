extends EnemyClass

func _physics_process(delta: float) -> void:
	process(delta)
	move_and_slide()
