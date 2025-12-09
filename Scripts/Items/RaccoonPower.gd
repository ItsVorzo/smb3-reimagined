extends PowerUps

var hover_timer := 0
var flying_timer := 0
var fly_mode_timer := 255
var attack_timer := 0
var anim_playing

func enter() -> void:
	pass

func physics_update(_delta: float) -> void:
	handle_timers()
	handle_hovering()
	handle_flying()

	owner.tailbox.monitoring = owner.tail_attacking
	anim_playing = owner.animated_sprite.is_playing()

	if owner.input.is_action_just_pressed("B") and not owner.tail_attacking:
		tail_attack()

func handle_timers():
	# Timer used to determine for how long will you fly upwards by tapping A ONCE
	if flying_timer > 0:
		flying_timer -= 1
		owner.velocity.y = -90.0
		if flying_timer > 10:
			owner.animated_sprite.play("fly")

	# Timer used to stay in flying mode
	if owner.flying or fly_mode_timer > 0 and fly_mode_timer < 255 and owner.tail_attacking:
		fly_mode_timer -= 1
	# Go upwards by tapping A
	if owner.flying:
		if owner.input.is_action_just_pressed("A"):
			flying_timer = 16
	if fly_mode_timer <= 0:
		owner.flying = false
		owner.p_meter = 0.0

	# Attacking timer
	if attack_timer > 0:
		attack_timer -= 1
	else:
		# Reset everything when you're done attacking
		owner.tail_attacking = false
		owner.animation_override = ""
		owner.direction_allow = true

func handle_hovering():
	owner.hovering = (not owner.tail_attacking and not owner.is_on_floor() and owner.velocity.y > 0 
					and owner.input.is_action_pressed("A") and not owner.flying)
	if owner.hovering:
		owner.velocity.y = min(owner.velocity.y, 16)

func handle_flying():
	if not owner.is_on_floor() and owner.p_meter >= owner.p_meter_max and fly_mode_timer > 0 and not owner.tail_attacking:
		if not owner.flying:
			owner.flying = true
			if fly_mode_timer == 0:
				fly_mode_timer = 255
			owner.animated_sprite.play("fly")
	elif owner.is_on_floor() or owner.p_meter <= 0.0:
		owner.flying = false
		flying_timer = 0
		fly_mode_timer = 255
	if owner.tail_attacking:
		owner.flying = false
		flying_timer = 0

	if owner.flying and not anim_playing:
		if owner.velocity.y < 0:
			owner.animated_sprite.frame = 0
		else:
			owner.animated_sprite.frame = 2

func tail_attack():
	SoundManager.play_sfx("Break", owner.global_position)
	owner.tail_attacking = true
	owner.direction_allow = false
	attack_timer = 15
	owner.animation_override = "tail_attack"

func exit() -> void:
	owner.flying = false
	owner.hovering = false
	owner.tail_attacking = false
	owner.animation_override = ""
