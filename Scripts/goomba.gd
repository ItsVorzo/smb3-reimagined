extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 500.0
@export var death_time: float = 1.0
@export var score_value: int = 100
@export var is_goombrat: bool = false

var direction: int = -1
var stomped: bool = false
var stuck: bool = false   # NEW: track if Goomba is stuck

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var stomp_area: Area2D = $HeadStompArea
@onready var death_area: Area2D = $DeathArea
@onready var ray_wall: RayCast2D = $RayCast2D_WallCheck
@onready var ray_ledge: RayCast2D = $RayCast2D_LedgeCheck
@onready var stomp_sound = $Stomp

func _ready() -> void:
	if is_goombrat:
		sprite.sprite_frames = load("res://Sprites/Enemies/goombrat.tres")
	else:
		sprite.sprite_frames = load("res://Sprites/Enemies/goomba.tres")

	sprite.play("walk")
	stomp_area.body_entered.connect(_on_head_stomp)
	death_area.body_entered.connect(_on_death_touch)

	ray_wall.enabled = true
	ray_ledge.enabled = is_goombrat
	_update_rays()

	# Start checking if Goomba gets stuck
	_check_stuck_loop()

func _physics_process(delta: float) -> void:
	if stomped:
		return

	velocity.y += gravity * delta

	# If stuck, don't move
	if not stuck:
		velocity.x = speed * direction
	else:
		velocity.x = 0

	if not stuck: # Only flip directions if not stuck
		if ray_wall.is_colliding():
			_flip_direction()
		if is_goombrat and not ray_ledge.is_colliding():
			_flip_direction()

	move_and_slide()

func _flip_direction() -> void:
	direction *= -1
	_update_rays()

func _update_rays() -> void:
	ray_wall.position.x = 8 * direction
	ray_wall.target_position.x = 1 * direction
	ray_ledge.position.x = 8 * direction
	ray_ledge.target_position.x = 1 * direction

func _on_head_stomp(body: Node) -> void:
	if stomped:
		return
	if not body.is_in_group("Player"):
		return
	if body.velocity.y >= 0:
		if body.has_method("bounce_on_enemy"):
			body.bounce_on_enemy()
		SaveManager.runtime_data["score"] = SaveManager.runtime_data.get("score", 0) + score_value
		if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
			SaveManager.hud.update_labels()
		_die()

func _on_death_touch(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("damage") and body.can_take_damage:
		body.damage()

func _die() -> void:
	stomped = true
	velocity = Vector2.ZERO

	# disable all collisions (player should not die after stomp)
	collider.disabled = true
	stomp_area.monitoring = false
	death_area.monitoring = false
	set_collision_layer(0)
	set_collision_mask(0)

	sprite.play("squish")
	stomp_sound.play()

	var timer := get_tree().create_timer(death_time)
	timer.timeout.connect(queue_free)

# ======================
# NEW: Stuck Detection
# ======================

func _check_stuck_loop() -> void:
	_check_stuck()
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(_check_stuck_loop)

func _check_stuck() -> void:
	var space_state = get_world_2d().direct_space_state

	# Ray to the left
	var left_params = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(-10, 0))
	left_params.exclude = [self]
	var left_result = space_state.intersect_ray(left_params)

	# Ray to the right
	var right_params = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(10, 0))
	right_params.exclude = [self]
	var right_result = space_state.intersect_ray(right_params)

	# Stuck only if both sides blocked
	if left_result and right_result:
		if not stuck:
			stuck = true
			sprite.play("stuck")
		# freeze only horizontal movement
		velocity.x = 0
	else:
		if stuck:
			stuck = false
			sprite.play("walk")
		# restore horizontal movement
		velocity.x = speed * direction
