extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 500.0
@export var death_time: float = 1.0
@export var score_value: int = 100
@export var is_goombrat: bool = false

var direction: int = -1
var stomped: bool = false

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

func _physics_process(delta: float) -> void:
	if stomped:
		return

	velocity.y += gravity * delta
	velocity.x = speed * direction

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
	if body.is_in_group("Player") and body.has_method("die"):
		body.die()

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
