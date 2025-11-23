extends PlayerState


func physics_process_update(_delta: float) -> void:

	# Player animations
	handle_animation()

	# Go to the death state
	if player.is_dead:
		state_machine.change_state("Die")

	# Handle the state switching between crouch and sliding
	if player.is_on_floor():
		if not state_machine.state.name == "Slide":
			# Switch to the sliding state when you're on a slope
			if player.input.is_action_pressed("down") and player.input_direction() == 0 and player.get_slope_angle() > 0:
				state_machine.change_state("Slide")
			# Floor's flat, crouch
			elif player.get_slope_angle() == 0:
				if player.is_super:
					if not player.test_move(player.global_transform, Vector2(0, -5)):
						player.crouching = player.input.is_action_pressed("down")
					# Unable to uncrouch because there's a ceiling
					else:
						player.crouching = true
				# Make the crouch work like usual when you're small
				else:
					player.crouching = player.input.is_action_pressed("down")
		# Reset the crouching flag
		if player.get_slope_angle() > 0 and player.crouching: player.crouching = false

	# === Horizontal Movement ===
	if not (player.crouching and player.is_on_floor()):
		if player.input_direction() == 1:
			if player.velocity.x < 0:
				player.velocity.x += player.skid_speed
			else:
				player.velocity.x = move_toward(player.velocity.x, player.final_max_speed(), player.acc_speed)
		elif player.input_direction() == -1:
			if player.velocity.x > 0:
				player.velocity.x -= player.skid_speed
			else:
				player.velocity.x = move_toward(player.velocity.x, -player.final_max_speed(), player.acc_speed)

	# If you aren't holding a direction, slow down
	if player.input_direction() == 0 and player.is_on_floor() or player.crouching and player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.frc_speed)


func handle_animation():
	# === Animation ===
	if player.current_grabbed_obj != null:
		if player.current_grabbed_obj.delaying:
			player.animation_override = "front_facing"
		else:
			player.animation_override = ""
	elif player.kick_timer == 0 and player.shoot_timer == 0:
			player.animation_override = ""
	
	# Override animations (animations that play over others)
	if player.animation_override != "":
		player.animated_sprite.play(player.animation_override)
	# Holding animations
	elif player.is_holding:
		if player.is_on_floor():
			if player.velocity.x == 0:
				player.animated_sprite.play("hold_idle")
			elif abs(player.velocity.x) > 0:
				player.animated_sprite.play("hold_walk", walk_anim_speed())
		else:
			player.animated_sprite.play("hold_jump")
	# Normal animations
	else:
		if player.crouching:
			player.animated_sprite.play("crouch")

		elif player.is_on_floor():
			if player.skidding:
				player.animated_sprite.play("skid")
			elif player.velocity.x == 0:
				player.animated_sprite.play("idle")
			elif abs(player.velocity.x) > 0 and abs(player.velocity.x) < player.p_speed and player.p_meter < player.p_meter_max:
				player.animated_sprite.play("walk", walk_anim_speed())
			else:
				player.animated_sprite.play("run", 7)
		else:
			if player.p_meter < player.p_meter_max:
				if player.velocity.y < 0 or player.pwrup.name == "Small":
					player.animated_sprite.play("jump")
				else:
					player.animated_sprite.play("fall")
			else:
				player.animated_sprite.play("fly")

func walk_anim_speed():
	if player.get_slope_angle() == 0: return max(1, 0.03 * abs(player.velocity.x))
	elif player.get_slope_direction() == player.velocity_direction: return 3
	else: return 4.5
