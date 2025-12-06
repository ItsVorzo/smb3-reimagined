extends PowerUps

var hover_timer := 0
var flying_timer := 0

func enter() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(_delta: float) -> void:
	if hover_timer > 0:
		hover_timer -= 1
	else:
		owner.hovering = false
		owner.animation_override = ""
	if flying_timer > 0:
		flying_timer -= 1
		owner.velocity.y = -90.0
		if flying_timer >= 10:
			owner.animated_sprite.play("fly")

	if not owner.is_on_floor() and owner.input.is_action_pressed("A") and not owner.flying:
		owner.hovering = true
	if owner.hovering:
		owner.velocity.y = min(owner.velocity.y, 16)
		owner.animated_sprite.play("hover")

	if owner.p_meter >= owner.p_meter_max and owner.input.is_action_just_pressed("A"):
		owner.animated_sprite.play("fly")
		owner.flying = true
	if owner.is_on_floor():
		owner.flying = false
	if owner.flying and owner.input.is_action_just_pressed("A"):
		flying_timer = 16

	if owner.flying and owner.velocity.y < 0:
		if not owner.animated_sprite.is_playing():
			owner.animated_sprite.frame = 0
	if owner.flying and owner.velocity.y > 0:
		owner.animated_sprite.frame = 1
