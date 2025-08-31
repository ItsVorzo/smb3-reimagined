extends EnemyClass

func _ready() -> void:
	set_signals()

func _physics_process(delta: float) -> void:
	process(delta)
	if stomped:
		return
	move_and_slide()
