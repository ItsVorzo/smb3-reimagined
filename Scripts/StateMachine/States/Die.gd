extends PlayerState

var can_fall := false

func enter() -> void:
	can_fall = false
	player.z_index = 99 # Draw the player above all
	player.is_dead = true
	# Notify level
	if get_tree().current_scene.has_method("on_player_death"):
		get_tree().current_scene.on_player_death(player)
	InputManager.input_disabled = true # Disable input
	get_tree().paused = true # Freeze the game
	player.animated_sprite.play("dead") # Play death animation

	# Disable collisions so Mario phases through everything
	player.normal_collision_shape.disabled = true
	player.super_collision_shape.disabled = true
	player.set_collision_layer(0)
	player.set_collision_mask(0)

	# Freeze the active camera exactly here (works no matter where the camera node lives)
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("freeze_here"):
		cam.freeze_here()

	player.velocity = Vector2.ZERO # Freeze the player
	# After 0.5 sec → short hop up if you didn't die from a pit
	if player.global_position.y < player.bottom_pit.global_position.y + 48:
		await get_tree().create_timer(0.5).timeout
		can_fall = true
		player.velocity.y = -224.0


func process_update(delta: float) -> void:
	if can_fall:
		player.velocity.y += player.death_gravity * delta
	player.move_and_slide()
