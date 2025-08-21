extends PlayerState


func enter() -> void:
	player.animated_sprite.play("slide")


func physics_process_update(_delta: float) -> void:
	if InputManager.direction != 0 or (player.get_slope_angle() == 0 and player.velocity.x == 0):
		state_machine.change_state("Normal")
	if player.velocity_direction != 0: 
		player.facing_direction = player.velocity_direction
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * player.get_slope_direction(), player.final_acc_speed())
