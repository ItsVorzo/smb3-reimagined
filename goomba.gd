extends CharacterBody2D

@export var speed := 30.0
@export var gravity := 500.0

var direction := -1  # Start moving left
var stomped := false

func _ready() -> void:
	$AnimatedSprite2D.play("walk")
	$RayCast2D_Left.enabled = true
	$RayCast2D_Right.enabled = true
	$RayCast2D_WallCheck.enabled = true
	
	$HeadStompArea.body_entered.connect(_on_head_stomp_area_body_entered)
	
	_update_wallcheck_position()

func _physics_process(delta: float) -> void:
	if stomped:
		velocity = Vector2.ZERO
		return
	
	velocity.y += gravity * delta
	velocity.x = speed * direction

	if direction == -1 and not $RayCast2D_Left.is_colliding():
		_flip_direction()
	elif direction == 1 and not $RayCast2D_Right.is_colliding():
		_flip_direction()

	if $RayCast2D_WallCheck.is_colliding():
		_flip_direction()

	move_and_slide()

func _flip_direction() -> void:
	direction *= -1
	$AnimatedSprite2D.flip_h = direction == -1
	_update_wallcheck_position()

func _update_wallcheck_position() -> void:
	# Flip wallcheck position to face direction instead of changing cast_to
	var pos = $RayCast2D_WallCheck.position
	pos.x = abs(pos.x) * direction
	$RayCast2D_WallCheck.position = pos

func _on_head_stomp_area_body_entered(body: Node) -> void:
	if stomped:
		return

	if body.has_method("bounce"):
		body.bounce()
	if body.has_method("play_squish_sound"):
		body.play_squish_sound()

	stomped = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.play("squish")
	
	start_death_timer()

func start_death_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_death_timer_timeout)

func _on_death_timer_timeout() -> void:
	queue_free()
