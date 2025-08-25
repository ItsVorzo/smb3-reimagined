extends EnemyClass

var xspd := -10.0  # Start moving left by default

func _ready() -> void:
	set_signals()

func _physics_process(_delta: float) -> void:
	process()

	if stomped:
		return

	# Reverse direction if hitting a wall
	if is_on_wall():
		xspd *= -1
		$Sprite.scale.x *= -1  # Flip sprite horizontally (optional)

	velocity.x = xspd
	move_and_slide()
