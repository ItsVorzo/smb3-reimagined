extends PlayerState


func enter() -> void:
	pass

func physics_process_update(_delta: float) -> void:
	handle_animation()
	if player.is_dead:
		state_machine.change_state("Die")
	if InputManager.down && player.is_on_floor():
		state_machine.change_state("Crouch")

func handle_animation():
	# === Animation ===
	if player.is_on_floor():
		if player.is_skidding:
			player.animated_sprite.play("skid")
		elif player.velocity.x == 0:
			player.animated_sprite.play("idle")
		elif abs(player.velocity.x) > 0 and abs(player.velocity.x) <= player.run_speed + player.downhill_speed_modifier():
			player.animated_sprite.play("walk", walk_anim_speed())
		elif player.max_speed == player.p_speed:
			player.animated_sprite.play("run", 6)
	else:
		if player.max_speed != player.p_speed:
			player.animated_sprite.play("jump")
		else:
			player.animated_sprite.play("fly")

func walk_anim_speed():
	if player.get_slope_angle() == 0: return max(1, 0.03 * abs(player.velocity.x))
	elif player.get_slope_direction() == player.velocity_direction: return 3
	else: return 4
