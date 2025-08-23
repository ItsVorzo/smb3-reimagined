extends CharacterBody2D

@export var fall_speed: float = 500.0
@export var return_speed: float = 100.0
@export var wait_time: float = 0.5

var start_position: Vector2
var is_falling = false
var is_returning = false

@onready var player_detector: Area2D = $PlayerDetector
@onready var crush_area: Area2D = $CrushArea

func _ready() -> void:
	start_position = global_position
	player_detector.body_entered.connect(_on_player_entered)
	crush_area.body_entered.connect(_on_crush_area_entered)
	player_detector.monitoring = true
	crush_area.monitoring = true
	velocity = Vector2.ZERO
	print("Thwomp ready.")

func _physics_process(delta: float) -> void:
	if is_falling:
		velocity.y = fall_speed
	elif is_returning:
		var dir = (start_position - global_position).normalized()
		velocity = dir * return_speed
		if global_position.distance_to(start_position) < 2.0:
			global_position = start_position
			velocity = Vector2.ZERO
			is_returning = false
			print("Returned to idle.")
	else:
		velocity = Vector2.ZERO

	if is_falling and is_on_floor():
		print("Thwomp hit ground!")
		is_falling = false
		await get_tree().create_timer(wait_time).timeout
		is_returning = true

	move_and_slide()

func _on_player_entered(body: Node) -> void:
	if body.is_in_group("Player") and not is_falling and not is_returning:
		print("Player detected — dropping!")
		is_falling = true

func _on_crush_area_entered(body: Node) -> void:
	if is_falling and body.is_in_group("Player"):
		if body.has_method("damage"):
			print("Player crushed!")
			body.damage()
