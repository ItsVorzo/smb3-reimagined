extends EnemyClass

var max_height := 0.0
var min_height := 0.0
var state := 0
var timer := 120

func _ready() -> void:
	init()
	max_height = global_position.y
	min_height = global_position.y + 24
	global_position.y = min_height

func _physics_process(delta: float) -> void:
	process(delta)
	move_and_slide()

	if dead_from_obj:
		z_index = 1
		return

	# Check if the player is near the pipe/plant
	var player_distance = INF
	for player in get_tree().get_nodes_in_group("Player"):
		var dist = abs(player.global_position.x - global_position.x)
		if dist < player_distance:
			player_distance = dist
	print(player_distance)

	match state:
		# Wait inside of the pipe
		0:
			if timer > 0:
				timer -= 1
			elif player_distance > 24.0:
				state = 1

		# Come out of the pipe
		1:
			if timer != 120:
				timer = 120
			if global_position.y > max_height:
				global_position.y -= 1
			else:
				state = 2

		# Wait outside of the pipe
		2:
			if timer > 0:
				timer -= 1
			else:
				state = 3

		# Get back inside
		3:
			if timer != 120:
				timer = 120
			if global_position.y < min_height:
				global_position.y += 1
			else:
				state = 0
