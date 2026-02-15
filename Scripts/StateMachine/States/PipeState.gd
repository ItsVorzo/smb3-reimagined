extends PlayerState

var start_pos := Vector2.ZERO
const PIPE_SPEED := 50

func enter() -> void:
	player.small_collision.disabled = true
	player.big_collision.disabled = true
	player.velocity = Vector2.ZERO
	player.direction_allow = false
	if player.pipe_enter_dir.x != 0:
		player.animated_sprite.scale.x = player.pipe_enter_dir.x 
	start_pos = player.global_position

func physics_process_update(delta: float) -> void:
	player.velocity = Vector2.ZERO
	if player.global_position.distance_to(start_pos) < 48:
		player.global_position += (PIPE_SPEED * (player.pipe_enter_dir)) * delta

func exit() -> void:
	player.direction_allow = true
