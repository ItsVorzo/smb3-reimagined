extends EnemyClass

var xspd := 10.0

func _ready() -> void:
	set_signals()

func _physics_process(_delta: float) -> void:
	process()
	if stomped:
		return
	velocity.x = xspd
	move_and_slide()
