extends CharacterBody2D

@export var speed: float = 30.0
@export var gravity: float = 500.0

var direction: int = -1

@onready var ray_wall: RayCast2D = $RayCast2D_WallCheck
@onready var death_area: Area2D = $DeathArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	ray_wall.enabled = true
	_update_rays()
	_update_sprite_flip()
	death_area.body_entered.connect(_on_death_touch)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = speed * direction

	if ray_wall.is_colliding():
		_flip_direction()

	move_and_slide()

func _flip_direction() -> void:
	direction *= -1
	_update_rays()
	_update_sprite_flip()

func _update_rays() -> void:
	ray_wall.position.x = 8 * direction
	ray_wall.target_position.x = 1 * direction

func _update_sprite_flip() -> void:
	sprite.flip_h = direction > 0

func _on_death_touch(body: Node) -> void:
	if body.is_in_group("Player") and body.has_method("damage") and body.can_take_damage:
		body.damage()
