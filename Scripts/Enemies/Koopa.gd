extends EnemyClass

@export_enum("Green", "Red") var color := "Green"
@export var wings := false
@onready var r_wing = $RightWing
@onready var ledgecheck = $LedgeCheck
var had_wings := false
var start_y
var jump_speed = -155.0
var timer := 0.0

func _ready() -> void:
	if wings and color == "Red":
		start_y = global_position.y
	if wings:
		r_wing.show()
		r_wing.position = Vector2(4, -11)
	else:
		r_wing.hide()
	init()
	sprite.play("Walk" + color)

func _physics_process(delta: float) -> void:
	process(delta)
	timer += delta
	sprite.scale.x = -direction
	r_wing.scale.x = -direction
	r_wing.position.x = 4 * -direction

	if dead_from_obj:
		if wings: wings = false
		r_wing.stop()
		r_wing.hide()

	if (not wings) or (wings and color == "Green"):
		move_horizontally()
		velocity.y = min(velocity.y, grav_speed)


	# Normal koopa behavior
	if not wings:
		if not is_on_floor(): 
			gravity(delta)
		if color == "Red" and is_on_floor() and not ledgecheck.is_colliding():
			direction *= -1
		ledgecheck.position.x = 4.0 * direction

	# Green parakoopa
	elif wings and color == "Green":
		if not is_on_floor(): 
			gravity(delta)
		if is_on_floor():
			velocity.y = jump_speed
		r_wing.play("flap")

	# Red parakoopa
	elif wings and color == "Red":
		global_position.y = start_y + 112 * ((sin(timer) + 1.0) / 2.0)
		r_wing.play("flap", 3)

	if not (wings and color == "Red"):
		move_and_slide()

	flip_direction()

# Spawn the shell
func on_stomped() -> void:
	if not wings:
		var shell = load("res://Scenes/Enemies/KoopaShell.tscn").instantiate()
		shell.global_position = global_position
		shell.shell_owner_spawn_pos = og_spawn_position
		shell.had_wings = had_wings
		shell.color = color
		get_parent().call_deferred("add_child", shell)
		queue_free()
	else:
		if velocity.y < 0:
			velocity.y = 0
		wings = false
		had_wings = true
		r_wing.stop()
		r_wing.hide()

func reset_enemy() -> void:
	if had_wings:
		wings = true
		had_wings = false
	_ready()
	timer = 0.0
