extends CharacterBody2D

@export var move_distance: float = 300.0
@export var max_speed: float = 40.0
@export var acceleration: float = 300.0
@export var wait_time: float = 0.3
@export var ease_in_time: float = 0.5 

var start_position: Vector2
var end_position: Vector2
var direction: int = 1
var is_waiting: bool = false
var easing_in: bool = false
var ease_timer: float = 0.0

var target_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	start_position = global_position
	end_position = start_position + Vector2(move_distance, 0)

func _physics_process(delta: float) -> void:
	if is_waiting:
		target_velocity = Vector2.ZERO
	else:
		var target_pos = end_position if direction == 1 else start_position
		var to_target = target_pos - global_position
		var dist = to_target.length()

		# Determine base speed (decelerates near end)
		var base_speed = max_speed
		if dist < 50:
			base_speed *= (dist / 50.0)  # ease out (decelerate)

		# Ease in after waiting
		if easing_in:
			ease_timer += delta
			var ease_factor = clamp(ease_timer / ease_in_time, 0.0, 1.0)
			base_speed *= ease_factor
			if ease_factor >= 1.0:
				easing_in = false  # Done easing in

		# Set target velocity
		target_velocity = to_target.normalized() * base_speed

		# Check if we reached the destination
		if dist < 1.0:
			global_position = target_pos
			direction *= -1
			target_velocity = Vector2.ZERO
			velocity = Vector2.ZERO
			is_waiting = true
			easing_in = false
			await get_tree().create_timer(wait_time).timeout
			_start_moving()

	# Smooth velocity transition
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	move_and_slide()

func _start_moving():
	is_waiting = false
	easing_in = true
	ease_timer = 0.0
