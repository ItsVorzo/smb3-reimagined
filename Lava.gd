extends EnemyClass

func _ready() -> void:
	init()
	remove_from_group("Enemies")

func _physics_process(delta: float) -> void:
	remove_from_group("Enemies")
	process(delta)
	move_and_slide()
