extends CharacterBody2D

@export var speed := 30.0
@export var gravity := 500.0

var direction := -1  # Start walking left

func _ready():
	print("Goomba is alive")
	global_position = Vector2(200, 100)  # Put it somewhere visible
	var marker = ColorRect.new()
	marker.color = Color.RED
	marker.size = Vector2(16, 16)
	add_child(marker)
	$HeadStompArea.body_entered.connect(_on_head_stomp_area_body_entered)
	$AnimatedSprite2D.play("walk")

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = speed * direction

	# Turn if no ground ahead (edge) or on wall
	if not $RayCast2D_Left.is_colliding() and direction == -1:
		direction = 1
		$AnimatedSprite2D.flip_h = false
	elif not $RayCast2D_Right.is_colliding() and direction == 1:
		direction = -1
		$AnimatedSprite2D.flip_h = true

	if is_on_wall():
		direction *= -1
		$AnimatedSprite2D.flip_h = direction == -1

	move_and_slide()

func _on_head_stomp_area_body_entered(body):
	if body.has_method("bounce"):
		body.bounce()
	queue_free()
