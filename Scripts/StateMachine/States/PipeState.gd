extends PlayerState

var start_pos := Vector2.ZERO
const PIPE_SPEED := 50

func enter() -> void:
	player.small_collision.disabled = true
	player.big_collision.disabled = true
	player.velocity = Vector2.ZERO
	start_pos = player.global_position

func physics_process_update(delta: float) -> void:
	player.velocity = Vector2.ZERO
	if player.global_position.distance_to(start_pos) < 48:
		player.global_position += (PIPE_SPEED * (player.pipe_enter_dir)) * delta
