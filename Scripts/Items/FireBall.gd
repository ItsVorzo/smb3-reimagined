extends CharacterBody2D

var xspd := 170.0
var bounce := 176.0
var direction := 1.0
@onready var area2d = $Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("spin")
	area2d.body_entered.connect(kill)

func _physics_process(delta: float) -> void:

	velocity.x = xspd * direction
	if is_on_floor():
		velocity.y = -bounce
	else:
		velocity.y += 1000.0 * delta

	if is_on_wall() or not GameManager.is_on_screen(global_position):
		if is_on_wall():
			SoundManager.play_sfx("Hit", global_position)
		queue_free()

	move_and_slide()

func kill(body: Node):

	if body.is_in_group("Enemies"):
		body.die_from_obj(direction, 60)
	elif body.is_in_group("Shell"):
		SoundManager.play_sfx("Kick", global_position)
		body.die(direction)

	queue_free()
