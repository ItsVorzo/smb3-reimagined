extends PlayerState

var can_fall := false
var c

func enter() -> void:
	player.process_mode = player.PROCESS_MODE_ALWAYS
	can_fall = false
	player.z_index = 99 # Draw the player above all
	player.is_dead = true
	InputManager.input_disabled = true # Disable input
	SoundManager.play_sfx("DieShort")
	if player.player_id == 0:
		# Notify level
		if get_tree().current_scene.has_method("on_player_death"):
			get_tree().current_scene.on_player_death(player)
		get_tree().paused = true # Freeze the game

		# Freeze the active camera exactly here (works no matter where the camera node lives)
		var cam := get_viewport().get_camera_2d()
		if cam and cam.has_method("freeze_here"):
			cam.freeze_here()

	player.velocity = Vector2.ZERO # Freeze the player
	# After 0.5 sec → short hop up if you didn't die from a pit
	if player.global_position.y < player.bottom_pit.global_position.y + 48:
		player.animated_sprite.play("dead") # Play death animation
		await get_tree().create_timer(0.5).timeout
		can_fall = true
		player.velocity.y = -224.0
	if player.player_id > 0:
		c = get_viewport().get_camera_2d()
		await get_tree().create_timer(2).timeout
		state_machine.change_state("Normal")


func process_update(delta: float) -> void:
	# Disable collisions so Mario phases through everything
	player.normal_collision_shape.disabled = true
	player.super_collision_shape.disabled = true

	if can_fall:
		player.velocity.y += player.death_gravity * delta

	player.move_and_slide()

func exit() -> void:
	player.is_dead = false
	player.process_mode = player.PROCESS_MODE_INHERIT
	player.normal_collision_shape.disabled = false
	player.super_collision_shape.disabled = false
	player.global_position = Vector2(player.global_position.x, -48)
	player.velocity.y = 0.0
