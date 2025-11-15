extends PowerUps

var fireball_amount := 0
var fireball_limit := 2
var fireball_scene = preload("res://Scenes/Items/FireBall.tscn")

func physics_update(_delta: float) -> void:

	if owner.input.is_action_just_pressed("B") and owner.state_machine.state.name == "Normal":
		if fireball_amount < fireball_limit:
			throw_fireball()

func throw_fireball():
	SoundManager.play_sfx("Fireball", owner.global_position)
	owner.shoot_timer = 10
	var fireball := fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = owner.global_position
	fireball.global_position.y = owner.global_position.y - 10
	fireball_amount += 1
	fireball.direction = owner.facing_direction

	# When the fireball dies, it should notify us
	fireball.connect("tree_exited", Callable(self, "on_fireball_die"))

func on_fireball_die():
	fireball_amount -= 1

func exit() -> void:
	owner.animation_override = ""
