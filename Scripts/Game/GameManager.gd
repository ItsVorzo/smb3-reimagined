extends Node

var p_meter := [] # Access everyone's p meter globally
var p_meter_max := 70
var p_switch_timer := 0.0

@warning_ignore("unused_signal") signal p_switch_activated
@warning_ignore("unused_signal") signal p_switch_expired

func _process(_delta: float) -> void:
	change_aspect_ratio()
	enemy_spawning_despawning()
	handle_p_switch()

func handle_p_switch() -> void:
	print(p_switch_timer)
	if p_switch_timer > 0:
		p_switch_timer -= 1
		if p_switch_timer <= 0:
			p_switch_timer = 0
			print("replaced")
			p_switch_expired.emit()

func change_aspect_ratio() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if ConfigManager.option_indices["Size"] == 0:
			ConfigManager.option_indices["Size"] = 1
		else:
			ConfigManager.option_indices["Size"] = 0
		ConfigManager._apply_options()

func enemy_spawning_despawning() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var shells = get_tree().get_nodes_in_group("Shell")
	var objects = enemies + shells

	# Handle enemy spawning and despwning
	for enemy in objects:
		# Disable enemies when offscreen
		if not GameManager.is_on_screen(enemy.global_position, 32, 32):
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
			enemy.visible = false
		# Enable respawns when you're far from the enemy spawn point
		if not enemy.visible and not GameManager.is_on_screen(enemy.og_spawn_position, 8, 8):
			enemy.can_respawn = true

		# Respawn and reset enemies when you go near the spawn point again
		if not enemy.visible and enemy.can_respawn and GameManager.is_on_screen(enemy.og_spawn_position, 8, 8):
			if enemy.is_in_group("Enemies"):
				var spawn_pos = enemy.og_spawn_position
				enemy.global_position = spawn_pos
			enemy.can_respawn = false
			enemy.reset_enemy()
			enemy.visible = true
			enemy.process_mode = Node.PROCESS_MODE_INHERIT

# Check if "obj" is visible on screen
func is_on_screen(pos, RegionW := 16, RegionH := 16):
	var screen_size = get_viewport().get_visible_rect().size
	var camera = get_viewport().get_camera_2d()

	if camera == null:
		return

	var cam_pos = camera.global_position

	return (pos.x > cam_pos.x - (screen_size.x / 2) - RegionW and
	pos.x < cam_pos.x + (screen_size.x / 2) + RegionW and
	pos.y > cam_pos.y - (screen_size.y / 2) - 46 - RegionH and
	pos.y < cam_pos.y + (screen_size.y / 2) + RegionH
	)

func first_player() -> CharacterBody2D:
	return get_tree().get_first_node_in_group("Player")

func get_players() -> Array:
	return get_tree().get_nodes_in_group("Player")

func nearest_player(pos) -> CharacterBody2D:
	var nearest_plr: CharacterBody2D = null
	var shortest_distance = INF

	for player in get_players():
		var distance = pos.distance_to(player.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_plr = player

	return nearest_plr
