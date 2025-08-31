extends EnemyClass

func _ready() -> void:
	set_signals()

func _physics_process(_delta: float) -> void:
	process()
	if stomped:
		return
	move_and_slide()
