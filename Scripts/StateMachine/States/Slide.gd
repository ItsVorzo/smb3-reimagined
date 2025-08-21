extends PlayerState


func enter() -> void:
	player.crouching = false
	player.animated_sprite.play("slide")


func physics_process_update(_delta: float) -> void:
	if player.get_slope_angle() == 0:
		if abs(player.velocity.x) < 10:
			state_machine.change_state("Normal")
		elif InputManager.direction != 0:
			state_machine.change_state("Normal")
	elif InputManager.direction != player.velocity_direction and InputManager.direction != 0 or not player.is_on_floor():
		state_machine.change_state("Normal")
	if player.velocity_direction != 0: 
		player.facing_direction = player.velocity_direction
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * player.get_slope_direction(), player.final_acc_speed())

func exit() -> void:
	pass
