extends EnemyClass

func _physics_process(delta: float) -> void:
	remove_from_group("Enemies")
	process(delta)
