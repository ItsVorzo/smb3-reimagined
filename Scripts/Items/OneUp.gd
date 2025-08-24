extends CharacterBody2D

@onready var sprite := $Sprite2D
@onready var collision := $Collision
@onready var pickup_area := $Area2D
@onready var ray_wall := $RayCast2D_WallCheck
@onready var oneup_sfx := $OneUpSfx
var from_block := false
var direction := 1
var xspd = 50.0
var gravity := 500.0

func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)
	# god this is so bad, will make a better way to do this
	if from_block:
		await get_tree().create_timer(0.5).timeout
		update_rays()
	else:
		update_rays()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.x = xspd * direction
	if not is_on_floor(): velocity.y += gravity * delta
	if ray_wall.is_colliding():
		flip_direction()
	if from_block:
		await get_tree().create_timer(0.5).timeout
		move_and_slide()
	else:
		move_and_slide()

func flip_direction() -> void:
	direction *= -1
	update_rays()

func update_rays() -> void:
	ray_wall.position.x = 8 * direction
	ray_wall.target_position.x = 1 * direction

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	# Add a life
	SoundManager.play_sfx("1UP", body.global_position)
	if SaveManager.hud:
		SaveManager.hud.update_labels()
	SaveManager.add_life(1)

	# Vanish
	queue_free()
	return
