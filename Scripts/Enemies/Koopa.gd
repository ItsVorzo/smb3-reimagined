extends EnemyClass

@export_enum("Green", "Red") var color := "Green"
@onready var ledgecheck = $LedgeCheck

func _ready() -> void:
	init()
	sprite.play("Walk" + color)

func _physics_process(delta: float) -> void:
	process(delta)
	move_horizontally()
	sprite.scale.x = -direction

	if not is_on_floor(): 
		gravity(delta)
	velocity.y = min(velocity.y, grav_speed)
	if color == "Red" and is_on_floor() and not ledgecheck.is_colliding():
		direction *= -1
	ledgecheck.position.x = 4.0 * direction

	move_and_slide()

	flip_direction()

# Spawn the shell
func on_stomped() -> void:
	var shell = load("res://Scenes/Enemies/KoopaShell.tscn").instantiate()
	shell.global_position = global_position
	shell.color = color
	get_parent().call_deferred("add_child", shell)
	queue_free()
