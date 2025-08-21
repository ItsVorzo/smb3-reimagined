extends PlayerState

func enter() -> void:
	player.animated_sprite.play("crouch")


func physics_process_update(_delta: float) -> void:
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.frc_speed)
		if !InputManager.down:
			state_machine.change_state("Normal")
