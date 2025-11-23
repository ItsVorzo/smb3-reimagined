extends CharacterBody2D

var gravity = 800.0
var jump_speed
var xspd := 50.0
var direction := 1

func _physics_process(delta: float) -> void:
	velocity.x = xspd * direction
	velocity.y += gravity * delta
	if not GameManager.is_on_screen(global_position):
		queue_free()
	move_and_slide()
