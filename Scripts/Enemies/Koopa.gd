extends EnemyClass

@export_enum("Green", "Red") var color := "Green"
@onready var ledgecheck = $LedgeCheck

func _ready() -> void:
	init()
	sprite.play("Walk" + color)

func _physics_process(delta: float) -> void:
	process(delta)

	# --- Disable walking ---
	velocity.x = 0
	direction = 0
	# ------------------------

	sprite.scale.x = -1  # keeps sprite facing one direction, optional

	# prevent red version from flipping at ledges
	if color == "Red":
		pass

	ledgecheck.position.x = 0

	move_and_slide()

	flip_direction()

# Spawn the shell
func on_stomped() -> void:
	var shell = load("res://Scenes/Enemies/KoopaShell.tscn").instantiate()
	shell.global_position = global_position
	shell.color = color
	get_parent().call_deferred("add_child", shell)
	queue_free()
