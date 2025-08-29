extends CharacterBody2D

@onready var grab = $Grabbable
var gravity = 500.0
var bounce_force = -80.0  # Smaller bounce
var has_bounced = false
var was_on_floor = false
var was_grabbed = false  # New: track previous grab state

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var is_currently_grabbed = grab.is_grabbed

	if not is_currently_grabbed:
		velocity.y += gravity * delta

		# Allow bounce if just released and hits the floor
		if is_on_floor() and not was_on_floor and not has_bounced and velocity.y > 0:
			velocity.y = bounce_force
			has_bounced = true
	else:
		# While being held
		velocity.y = 0

	# Reset bounce if it was just released
	if was_grabbed and not is_currently_grabbed:
		has_bounced = false

	# Update state trackers
	was_on_floor = is_on_floor()
	was_grabbed = is_currently_grabbed

	move_and_slide()
