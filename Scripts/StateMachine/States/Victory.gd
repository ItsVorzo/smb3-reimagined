extends PlayerState


func enter() -> void:
	player.velocity.x = 0
	player.facing_direction = 1
	player.direction_allow = false
	player.can_take_damage = false
	player.goal_completed = true
	player.hitbox.set_deferred("monitoring", false)

func physics_process_update(delta: float) -> void:
	player.apply_gravity(delta)
	if player.is_on_floor():
		player.velocity.x = player.end_level_walk
		player.animated_sprite.play("walk", 2)
