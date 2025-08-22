extends PowerUpItem

@onready var sprite := $Sprite2D
@onready var collision := $Collision
@onready var ray_wall := $RayCast2D_WallCheck
var xspd = 50.0
var gravity := 500.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.x = xspd * direction
	if not is_on_floor(): velocity.y += gravity * delta
	if ray_wall.is_colliding():
		flip_direction()
	if from_block:
		await get_tree().create_timer(0.5).timeout
		update_rays()
		move_and_slide()
	else:
		update_rays()
		move_and_slide()

func flip_direction() -> void:
	direction *= -1
	update_rays()

func update_rays() -> void:
	ray_wall.position.x = 8 * direction
	ray_wall.target_position.x = 1 * direction

#func _on_body_entered(body: Node) -> void:
#	if not body.is_in_group("Player"):
#		return

#	body.is_super = true
#	body.power_up_animation("Big")

#	# Vanish
#	queue_free()
