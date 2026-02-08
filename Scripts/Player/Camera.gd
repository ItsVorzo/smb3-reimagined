class_name Camera
extends Camera2D

@onready var Plr: CharacterBody2D = $"../Player" # Main player node
@onready var camlimit_left := $"../CameraLimitLeft"
@onready var camlimit_right := $"../CameraLimitRight"
@onready var camlimit_ground := $"../CameraGroundLimit"
var center_x = 0.0
var center_y = 0.0
var shift_x: float = 0.0
var shift_y: float = 0.0
var side_margin: float = 8.0
var top_margin: float = 84.0
var bottom_margin: float = -40.0


var frozen := false
var frozen_position := Vector2.ZERO

func _process(_delta: float) -> void:
	# Get the camera center
	center_x = (get_viewport().get_visible_rect().size.x / 2)
	center_y = (get_viewport().get_visible_rect().size.y / 2)

	if frozen:
		# Keep camera completely locked
		global_position = frozen_position
		# Still apply player clamping but allow goal-completed players to go off-screen
		for p in GameManager.get_players():
			# Only clamp players who haven't completed the goal
			if not p.goal_completed:
				p.global_position.x = clamp(p.global_position.x, camlimit_left.global_position.x + 16, camlimit_right.global_position.x - 16)
				if p.global_position.x <= camlimit_left.global_position.x + 16 and p.velocity.x < 0 or p.global_position.x >= camlimit_right.global_position.x - 16 and p.velocity.x > 0:
					p.velocity.x = 0
		return

	# CameraMode handling from ConfigManager
	match ConfigManager.option_indices["CameraMode"]:
		0: # off
			shift_x = 0
		1: # fixed panning
			side_margin = 0.0
			if abs(Plr.velocity.x) > 30:
				shift_x = move_toward(shift_x, 30.0 * Plr.facing_direction, 0.4)
			elif Plr.velocity.x == 0:
				shift_x = move_toward(shift_x, 0, 0.4)
		2: # smooth panning
			side_margin = 0.0
			if abs(Plr.velocity.x) > 0:
				shift_x = lerp(shift_x, Plr.velocity.x / 5.0, 0.1)
			elif Plr.velocity.x == 0:
				shift_x = lerp(shift_x, 0.0, 0.1)

	# Reference all of the other players
	var players = get_tree().get_nodes_in_group("Player")

	var camera_x 
	var camera_y
	# Only the main player can control the camera
	for p in players:
		if p.player_id == 0:
			# Move the camera horizontally
			var final_x_pos = global_position.x
			if p.global_position.x < global_position.x - side_margin:
				final_x_pos = p.global_position.x + side_margin
			if p.global_position.x > global_position.x + side_margin:
				final_x_pos = p.global_position.x - side_margin
			
			camera_x = clamp(final_x_pos + shift_x, camlimit_left.position.x + center_x, camlimit_right.position.x - center_x)

			# Move the camera vertically
			var final_y_pos = global_position.y
			if p.p_meter >= p.p_meter_max or p.flying:
				if p.global_position.y < global_position.y - top_margin:
					final_y_pos = p.global_position.y + top_margin
			if p.global_position.y > global_position.y + bottom_margin:
				final_y_pos = p.global_position.y - bottom_margin

			camera_y = min(final_y_pos + shift_y, camlimit_ground.global_position.y)

			# Apply position if not frozen
			global_position.x = camera_x
			global_position.y = camera_y

	for p in players:
		# Don't let the players go offscreen (unless they've completed the goal)
		if not p.goal_completed:
			p.global_position.x = clamp(p.global_position.x, camlimit_left.global_position.x + 16, camlimit_right.global_position.x - 16)
			if p.global_position.x <= camlimit_left.global_position.x + 16 and p.velocity.x < 0 or p.global_position.x >= camlimit_right.global_position.x - 16 and p.velocity.x > 0:
				p.velocity.x = 0
		
		if p.player_id >= 1:
			if not p.is_dead and not p.goal_completed:
				# Drag the other players with the camera horizontally
				p.global_position.x = clamp(p.global_position.x, global_position.x - center_x + 8, global_position.x + center_x - 8) 
				if p.global_position.x <= global_position.x - center_x + 8 and p.velocity.x < 0 or p.global_position.x >= global_position.x + center_x - 8 and p.velocity.x > 0:
					p.velocity.x = 0.0

func freeze_here():
	frozen = true
	frozen_position = global_position

func move_upward(duration: float, speed: float):
	frozen = false
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", global_position.y - (speed * duration), duration)
	await tween.finished
	frozen = true
	frozen_position = global_position
