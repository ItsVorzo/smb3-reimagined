extends EnemyClass

@export_enum("Red", "Green") var color := "Red"
@export var fire := false
var max_height := 0.0
var min_height := 0.0
var state := 0
var timer := 120
var aim_timer := 60
var has_shot = false
var fireball_scene = preload("res://Scenes/Enemies/PiranhaFireBall.tscn")
var aim_x_direction = 1
var aim_y_direction = 1

func _ready() -> void:
	super._ready()
	if not fire:
		sprite.play("Chomp" + color)
	else:
		sprite.play("Shoot" + color + str(int(aim_y_direction)))
	max_height = global_position.y
	min_height = global_position.y + 24
	global_position.y = min_height

func _physics_process(delta: float) -> void:
	process(delta)
	move_and_slide()

	if dead_from_obj:
		sprite.stop()
		z_index = 1
		return

	# Check if the player is near the pipe/plant
	var player_distance = INF
	var dist = abs(GameManager.nearest_player(global_position).global_position.x - global_position.x)
	if dist < player_distance:
		player_distance = dist

	# Get the aiming
	if fire:
		aim_y_direction = sign(GameManager.nearest_player(global_position).global_position.y - global_position.y)
		aim_x_direction = sign(GameManager.nearest_player(global_position).global_position.x - global_position.x)
		sprite.scale.x = -aim_x_direction
		if state != 2:
			sprite.play("Shoot" + color + str(int(aim_y_direction)))
		else:
			if aim_timer > 0:
				sprite.animation = "Shoot" + color + str(int(aim_y_direction))
				sprite.frame = 1
			else:
				sprite.animation = "Shoot" + color + str(int(aim_y_direction))
				sprite.frame = 0

	match state:
		# Wait inside of the pipe
		0:
			if timer > 0:
				timer -= 1
			elif player_distance > 24.0:
				state = 1

		# Come out of the pipe
		1:
			if global_position.y > max_height:
				global_position.y -= 1
			else:
				if not fire:
					timer = 120
				else:
					aim_timer = 60
					timer = 60
				state = 2

		# Wait outside of the pipe
		2:
			if not fire:
				if timer > 0:
					timer -= 1
				else:
					state = 3
			else:
				if aim_timer > 0:
					aim_timer -= 1
				elif not has_shot:
					shoot_fireball()
					has_shot = true 
				if timer > 0 and aim_timer == 0:
					timer -= 1
				if timer == 0 and aim_timer == 0:
					state = 3

		# Get back inside
		3:
			if global_position.y < min_height:
				global_position.y += 1
			else:
				timer = 120
				has_shot = false
				state = 0

func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.velocity.x = 40 * aim_x_direction
	fireball.velocity.y = 40 * aim_y_direction
	fireball.color = color
	fireball.z_index = 0
	get_parent().add_child(fireball)
	fireball.global_position.x = global_position.x + 4 * aim_x_direction
	fireball.global_position.y = owner.global_position.y - 64

func reset_enemy() -> void:
	_ready()
	state = 0
	timer = 120
	aim_timer = 60
	has_shot = false
	aim_x_direction = 1
	aim_y_direction = 1
