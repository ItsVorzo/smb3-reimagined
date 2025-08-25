extends EnemyClass  # EnemyClass extends CharacterBody2D

@export var ball_scene: PackedScene = preload("res://Scenes/Enemies/Ball.tscn")
var ball_instance: Node2D  # Reference to the spawned ball

var xspd := -30.0
var gravity := 1000.0
var max_fall_speed := 2000.0

const BALL_OFFSET_Y := -60.0  # Distance above the enemy (tweak as needed)

func _ready() -> void:
	set_signals()
	spawn_ball_above()

func _physics_process(delta: float) -> void:
	process()

	if stomped:
		return

	# Gravity and movement
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)
	velocity.x = xspd
	move_and_slide()

	# Wall detection
	if is_on_wall():
		xspd *= -1
		flip_sprite()

	# Keep ball positioned above enemy
	if ball_instance:
		ball_instance.global_position = global_position + Vector2(0, BALL_OFFSET_Y)

func spawn_ball_above():
	if ball_instance:
		return  # Already spawned

	ball_instance = ball_scene.instantiate()
	get_parent().add_child(ball_instance)
	ball_instance.global_position = global_position + Vector2(0, BALL_OFFSET_Y)

func flip_sprite() -> void:
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sprite.scale.x *= -1
