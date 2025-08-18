extends Node2D

@export_enum("Overworld", "Underground", "Desert", "Snow") var theme: String = "Overworld"

@onready var terrain_tilemap = $TerrainTileMap
@onready var semisolid_tilemap = $SemisolidTileMap
@onready var pipe_tilemap = $PipeTileMap
@onready var bgm = $Player/BGM
@onready var hud = $HUD
@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player

var save_index := 0
const BLOCK_SIZE := 16

func _ready() -> void:
	SaveManager.start_runtime_from_save(save_index)
	SaveManager.hud = hud
	SaveManager.hud.update_labels()
	apply_theme()

func apply_theme():
	# === TileMaps ===
	var terrain_path = "res://Sprites/Tilesets/%s/%s.tres" % [theme, theme]
	terrain_tilemap.tile_set = load(terrain_path)

	var semisolid_path = "res://Sprites/Tilesets/%s/Semisolid.tres" % theme
	semisolid_tilemap.tile_set = load(semisolid_path)

	var pipe_path = "res://Sprites/Gizmos/Pipes.tres" if theme == "Overworld" \
		else "res://Sprites/Gizmos/Variants/%s/Pipes.tres" % theme
	pipe_tilemap.tile_set = load(pipe_path)

	# === Music ===
	var music_path = "res://Audio/BGM/%s.ogg" % theme
	bgm.stream = load(music_path)
	bgm.play()

	# === Blocks / Objects ===
	apply_theme_to_blocks(self)


# Recursively walk scene tree and re-skin blocks
func apply_theme_to_blocks(node: Node) -> void:
	for child in node.get_children():
		# If the node has a custom apply_theme method, call it
		if child.has_method("apply_theme"):
			child.apply_theme(theme)
		# Otherwise, check if it’s a generic block we need to reskin
		elif child is Sprite2D or child is AnimatedSprite2D:
			# Simple fallback: try to load a texture atlas based on theme
			if "QuestionBlock" in child.name:
				var tex_path = "res://Sprites/Blocks/%s/QuestionBlock.png" % theme
				if ResourceLoader.exists(tex_path):
					child.texture = load(tex_path)
			elif "BrickBlock" in child.name:
				var tex_path = "res://Sprites/Blocks/%s/BrickBlock.png" % theme
				if ResourceLoader.exists(tex_path):
					child.texture = load(tex_path)

		# Recurse deeper
		apply_theme_to_blocks(child)

func on_player_death(player: Player) -> void:
	# Stop background music
	if bgm.playing:
		bgm.stop()

	# === Freeze the camera using the camera script's API ===
	# (Your Camera is a child of Level; it has freeze_here())
	if camera and camera.has_method("freeze_here"):
		camera.freeze_here()
	else:
		# fallback: lock the camera in place
		if camera:
			camera.position = player.global_position

	# === Pause the HUD time counter (no 'has()' call) ===
	if SaveManager.hud:
		if SaveManager.hud.has_method("pause_time"):
			SaveManager.hud.pause_time()
		elif SaveManager.hud.has_method("set_time_running"):
			SaveManager.hud.set_time_running(false)
		else:
			# fallback for HUDs that read runtime_data
			SaveManager.runtime_data["timer_paused"] = true

	# Play death sound
	player.death_sound.play()

	# After 0.36 sec → short hop up (≈3.5 blocks)
	var pause_timer := get_tree().create_timer(0.36)
	pause_timer.timeout.connect(func():
		var jump_blocks := 3.5
		player.velocity = Vector2.ZERO
		player.velocity.y = -sqrt(2 * player.grav_speed * BLOCK_SIZE * jump_blocks)
		player.death_state = "jump"
	)

	# When death sound finishes → decrement life and go to the correct world map
	player.death_sound.finished.connect(func():
		var lives = int(SaveManager.runtime_data.get("lives", 3))
		SaveManager.runtime_data["lives"] = max(0, lives - 1)
		SaveManager.commit_runtime_to_save(save_index)

		if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
			SaveManager.hud.update_labels()

		var world_number = int(SaveManager.runtime_data.get("world_number", 1))
		var map_path = "res://Scenes/WorldMaps/world_%d.tscn" % world_number
		if ResourceLoader.exists(map_path):
			get_tree().change_scene_to_file(map_path)
		else:
			push_error("World map not found: %s" % map_path)

		InputManager.input_disabled = false
	)
	
