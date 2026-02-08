extends Node2D

@onready var item_roulette: AnimatedSprite2D = $ItemRoulette
@onready var detection_area: Area2D = $DetectionArea
@onready var goal_background: Sprite2D = $GoalBackground
@onready var sparkle: AnimatedSprite2D = $Sparkle
@onready var firework: AnimatedSprite2D = $Firework

# Roulette cycling speed
const CYCLE_SPEED := 8
var cycle_timer := 0
var current_item_index := 0
var items := ["Mushroom", "FireFlower", "Star"]
var is_activated := false

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	item_roulette.animation = items[current_item_index]
	item_roulette.play()
	sparkle.visible = false
	firework.visible = false

func _physics_process(_delta: float) -> void:
	if is_activated:
		return

	cycle_timer += 1
	if cycle_timer >= CYCLE_SPEED:
		cycle_timer = 0
		current_item_index = (current_item_index + 1) % items.size()
		item_roulette.animation = items[current_item_index]
		item_roulette.play()

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return

	if body is Player:
		activate_goal(body)

func activate_goal(player: Player) -> void:
	is_activated = true
	var landed_item: String = items[current_item_index]

	# Check if this will be a 3-card match
	var cards = SaveManager.runtime_data.get("goal_items", [])
	var will_be_three_cards = (cards.size() == 2)
	var is_all_match = false

	if will_be_three_cards:
		is_all_match = (cards[0] == cards[1] and cards[1] == landed_item)

	# Award item first
	award_item_to_inventory(landed_item)

	# Lock down player
	for p in GameManager.get_players():
		p.state_machine.change_state("Victory")
	
	var level = get_tree().current_scene

	# Stop time counter
	if level.has_node("HUD"):
		level.get_node("HUD").pause_time()

	# Stop current music
	if level.has_node("Player/BGM"):
		var bgm = level.get_node("Player/BGM")
		if bgm.playing:
			bgm.stop()

	# Choose music based on match type
	var complete_music := AudioStreamPlayer2D.new()
	add_child(complete_music)
	if is_all_match:
		complete_music.stream = load("res://Audio/BGM/HitGoalOrb.ogg")
		await do_firework_sequence(player, landed_item, level, complete_music)
	else:
		complete_music.stream = load("res://Audio/BGM/HitGoalBox.ogg")
		await do_normal_sequence(player, landed_item, level, complete_music)

func do_normal_sequence(player: Player, landed_item: String, level, complete_music: AudioStreamPlayer2D):
	# Play spin animation
	item_roulette.animation = "Spin" + landed_item
	item_roulette.play()

	# Move item upward
	var tween := create_tween()
	tween.tween_property(item_roulette, "position:y", item_roulette.position.y - 200, 2.0)

	# Freeze camera
	if level.has_method("freeze_camera_at_position"):
		level.freeze_camera_at_position(level.camera.global_position)

	complete_music.play()

	# Show "Course clear !"
	await get_tree().create_timer(1.60).timeout
	if level.has_node("HUD"):
		level.get_node("HUD").show_course_clear()

	# Show card message
	await get_tree().create_timer(0.80).timeout
	if level.has_node("HUD"):
		level.get_node("HUD").show_card_message(landed_item)

	await get_tree().create_timer(0.3).timeout
	if level.has_node("HUD"):
		level.get_node("HUD").show_finish_score(false)

	await complete_music.finished
	await finish_level_sequence(player, landed_item, level, false)

func do_firework_sequence(player: Player, landed_item: String, level, complete_music: AudioStreamPlayer2D):
	# Play spin animation
	item_roulette.animation = "Spin" + landed_item
	item_roulette.play()

	# Calculate upward movement speed
	var move_distance = 200.0
	var move_duration = 1.60
	var move_speed = move_distance / move_duration

	# Move item and camera upward together
	var item_tween := create_tween()
	item_tween.tween_property(item_roulette, "position:y", item_roulette.position.y - move_distance, move_duration)

	# Move camera upward
	if level.has_node("Camera"):
		level.camera.move_upward(move_duration, move_speed)

	complete_music.play()

	# Wait for movement to finish
	await get_tree().create_timer(move_duration).timeout

	# Hide spinning item and show sparkle
	item_roulette.visible = false
	sparkle.visible = true
	sparkle.global_position = item_roulette.global_position
	sparkle.play()

	# Wait for sparkle
	await get_tree().create_timer(0.25).timeout
	sparkle.visible = false

	# Show firework
	firework.visible = true
	firework.global_position = item_roulette.global_position
	firework.animation = landed_item

	# Start manual ping-pong animation for frames 2-4
	var firework_active = true
	var animate_firework = func():
		# Play first 2 frames normally
		firework.frame = 0
		firework.play()
		await get_tree().create_timer(0.2).timeout

		# Now ping-pong loop frames 2-4
		var direction = 1
		firework.frame = 2
		while firework_active:
			await get_tree().create_timer(0.1).timeout
			firework.frame += direction
			if firework.frame >= 4:
				direction = -1
			elif firework.frame <= 2:
				direction = 1

	# Start the animation in background
	animate_firework.call()

	# Show card message
	await get_tree().create_timer(0.80).timeout
	if level.has_node("HUD"):
		level.get_node("HUD").show_card_message(landed_item, true)

	await get_tree().create_timer(0.3).timeout
	if level.has_node("HUD"):
		level.get_node("HUD").show_finish_score(true)

	# Wait for music to finish
	await complete_music.finished

	await finish_level_sequence(player, landed_item, level, true)

func finish_level_sequence(player: Player, landed_item: String, level, is_all_match: bool):
	# Time bonus countdown
	await time_bonus_countdown(level)

	var cards = SaveManager.runtime_data.get("goal_items", [])
	var hud = level.get_node("HUD") if level.has_node("HUD") else null

	if cards.size() == 3:
		if is_all_match:
			if hud:
				hud.start_all_cards_cascade_blink()
			var lives_to_give = 0
			match landed_item:
				"Mushroom": lives_to_give = 2
				"FireFlower": lives_to_give = 3
				"Star": lives_to_give = 5

			for i in range(lives_to_give):
				SoundManager.play_sfx("1UP", global_position)
				SaveManager.add_life(1)
				if hud:
					hud.update_labels()
				# Wait for 1UP sound to finish (~0.8s)
				await get_tree().create_timer(0.8).timeout
		else:
			if hud:
				hud.start_all_cards_cascade_blink()
			await get_tree().create_timer(0.5).timeout
			SoundManager.play_sfx("1UP", global_position)
			SaveManager.add_life(1)
			if hud:
				hud.update_labels()
	else:
		if hud:
			var card_slot_index = cards.size() - 1
			hud.start_card_blink_infinite(card_slot_index, landed_item)

	await get_tree().create_timer(3.0).timeout
	
	if hud:
		hud.stop_card_blink()
		if cards.size() == 3:
			SaveManager.runtime_data["goal_items"] = []
			hud.update_card_slots()

	# Save powerup state
	SaveManager.runtime_data["powerup_state"] = player.pwrup.name
	SaveManager.commit_runtime_to_save(level.save_index)

	InputManager.input_disabled = false
	TransitionManager.fade_in(6.0)
	await get_tree().create_timer(0.3).timeout

	var world_number = int(SaveManager.runtime_data.get("world_number", 1))
	var map_path = "res://Scenes/WorldMaps/World%d.tscn" % world_number
	get_tree().change_scene_to_file(map_path)

func award_item_to_inventory(item: String) -> void:
	if SaveManager.runtime_data.has("goal_items"):
		SaveManager.runtime_data["goal_items"].append(item)
	else:
		SaveManager.runtime_data["goal_items"] = [item]

func time_bonus_countdown(level) -> void:
	var current_time = int(SaveManager.get_temp("time", 0))

	while current_time > 0:
		if not is_inside_tree():
			return

		if current_time >= 10:
			current_time -= 10
			SaveManager.set_temp("time", current_time)
			SaveManager.add_score(500)
		else:
			current_time -= 1
			SaveManager.set_temp("time", current_time)
			SaveManager.add_score(50)

		SoundManager.play_sfx("Text", global_position)

		if level and level.has_node("HUD"):
			var hud = level.get_node("HUD")
			hud.update_labels()
			hud.update_finish_score_from_time()

		await get_tree().create_timer(0.03).timeout
