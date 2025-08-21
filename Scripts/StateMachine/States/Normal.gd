extends PlayerState


func enter() -> void:
	pass

func physics_process_update(_delta: float) -> void:
	handle_animation()
	if player.is_dead:
		state_machine.change_state("Die")
	if player.is_on_floor():
		if not state_machine.state.name == "Slide":
			if InputManager.down and InputManager.direction == 0 and player.get_slope_angle() > 0:
				state_machine.change_state("Slide")
			elif player.get_slope_angle() == 0:
				player.crouching = InputManager.down
	if player.get_slope_angle() > 0 and player.crouching: player.crouching = false

	# === Horizontal Movement ===
	if not (player.crouching and player.is_on_floor()):
		if InputManager.direction == 1:
			if player.velocity.x < 0:
				player.skidding = true
				player.velocity.x += player.skid_speed
			else:
				player.skidding = false
				player.velocity.x = move_toward(player.velocity.x, player.final_max_speed(), player.acc_speed)
		elif InputManager.direction == -1:
			if player.velocity.x > 0:
				player.skidding = true
				player.velocity.x -= player.skid_speed
			else:
				player.skidding = false
				player.velocity.x = move_toward(player.velocity.x, -player.final_max_speed(), player.acc_speed)

	# If you aren't holding a direction, slow down
	if InputManager.direction == 0 and player.is_on_floor() or player.crouching and player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.frc_speed)

func handle_animation():
	# === Animation ===
	if player.crouching:
		player.animated_sprite.play("crouch")

	elif player.is_on_floor():
		if player.skidding:
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
