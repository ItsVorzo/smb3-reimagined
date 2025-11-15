extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var shells = get_tree().get_nodes_in_group("Shell")
	var objects = enemies + shells
	for enemy in objects:
		if not GameManager.is_on_screen(enemy.global_position):
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			enemy.process_mode = Node.PROCESS_MODE_INHERIT

# Check if "obj" is visible on screen
func is_on_screen(pos, RegionW := 16, RegionH := 16):
	var screen_size = get_viewport().get_visible_rect().size
	var camera = get_viewport().get_camera_2d()

	if camera == null:
		return

	var cam_pos = camera.global_position

	return (pos.x > cam_pos.x - (screen_size.x / 2) / 3 - RegionW and
	pos.x < cam_pos.x + (screen_size.x / 2) / 3 + RegionW and
	pos.y > cam_pos.y - (screen_size.y / 2) / 3 - 46 - RegionH and
	pos.y < cam_pos.y + (screen_size.y / 2) / 3 + RegionH
	)
