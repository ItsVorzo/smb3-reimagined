extends PowerUps

var hover_timer := 0
var flying_timer := 0
var fly_mode_timer := 255

func enter() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta: float) -> void:
	if hover_timer > 0:
		hover_timer -= 1
	else:
		owner.hovering = false
		owner.animation_override = ""

	if not owner.is_on_floor() and owner.input.is_action_pressed("A") and not owner.flying:
		owner.hovering = true
	if owner.hovering:
		owner.velocity.y = min(owner.velocity.y, 16)
		owner.animated_sprite.play("hover")

	if flying_timer > 0:
		flying_timer -= 1
		owner.velocity.y = -90.0

	if not owner.is_on_floor() and owner.p_meter >= owner.p_meter_max and fly_mode_timer > 0:
		if not owner.flying:
			owner.flying = true
			fly_mode_timer = 255
			owner.animated_sprite.play("fly")
	elif owner.is_on_floor() or owner.p_meter <= 0.0:
		owner.flying = false
		flying_timer = 0
		fly_mode_timer = 255
	if owner.flying and owner.input.is_action_just_pressed("A"):
		flying_timer = 16
		owner.animated_sprite.play("fly")

	if owner.flying:
		fly_mode_timer -= 1
		if owner.input and owner.input.is_action_just_pressed("A"):
			flying_timer = 16

	if fly_mode_timer <= 0:
		owner.flying = false
		owner.p_meter = 0.0

func exit() -> void:
	owner.flying = false
