extends EnemyClass

@export var jump_force := -350.0
@export var jump_interval := 2.0

var start_y := 0.0
var jump_cooldown := 0.0
var jumping := false

@onready var spr: AnimatedSprite2D = $Area2D/AnimatedSprite2D

func _ready() -> void:
	start_y = global_position.y
	jump_cooldown = jump_interval
	init()

func _physics_process(delta: float) -> void:
	if stomped:
		return

	if not jumping:
		jump_cooldown -= delta
		if jump_cooldown <= 0.0:
			_start_jump()

	if jumping:
		gravity(delta)

		spr.flip_v = velocity.y > 0

		if global_position.y >= start_y and velocity.y > 0:
			global_position.y = start_y
			velocity.y = 0
			jumping = false
			jump_cooldown = jump_interval
			spr.flip_v = false
	else:
		velocity.y = 0
		spr.flip_v = false

	move_and_slide()
	process(delta)

func _start_jump() -> void:
	jumping = true
	velocity.y = jump_force
