extends PlayerState


func enter() -> void:
	player.crouching = false
	player.animated_sprite.play("slide")


func physics_process_update(_delta: float) -> void:
	# Switch to the normal state
	if player.input.is_action_just_pressed("A"):
		state_machine.change_state("Normal")
	if player.get_slope_angle() == 0:
		if abs(player.velocity.x) < 10:
			state_machine.change_state("Normal")
		elif player.input_direction() != 0:
			state_machine.change_state("Normal")
	elif player.input_direction() != player.velocity_direction and player.input_direction() != 0:
		state_machine.change_state("Normal")

	# Change the facing direction
	if player.velocity_direction != 0: 
		player.facing_direction = player.velocity_direction
	# Sliding, weeeeeeee
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * player.get_slope_direction(), player.final_acc_speed())
