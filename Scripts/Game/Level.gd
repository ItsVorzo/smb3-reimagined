extends Node2D

@export_enum("Overworld", "Underground", "Desert", "Snow", "Athletic", "Castle") var theme: String = "Overworld"
@export_enum("None", "Sliding", "Coming out of pipe") var entrance: String = "None"

@onready var terrain_tilemap = $TerrainTileMap
@onready var semisolid_tilemap = $SemisolidTileMap
@onready var pipe_tilemap = $PipeTileMap
@onready var bgm = $Player/BGM
@onready var hud = $HUD
@onready var camera: Camera2D = $Camera
@onready var plr: Player = $Player
@onready var bottom_pit: Area2D = $CameraGroundLimit

var save_index := 0
const BLOCK_SIZE := 16

func _ready() -> void:
	TransitionManager.fade_out(6.0)
	SaveManager.start_runtime_from_save(save_index)
	SaveManager.hud = hud
	SaveManager.hud.update_labels()
	apply_theme()

func apply_theme():
	# === TileMaps ===
	var terrain_path = "res://SpriteFrames/%s/%s.tres" % [theme, theme]
	terrain_tilemap.tile_set = load(terrain_path)

	var semisolid_path = "res://SpriteFrames/%s/Semisolid.tres" % theme
	semisolid_tilemap.tile_set = load(semisolid_path)

	var pipe_path = "res://SpriteFrames/Gizmos/Variants/%s/Pipes.tres" % theme
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
	if bgm.playing: bgm.stop() # Stop background music
	player.death_sound.play() # Play death sound
	TransitionManager.fade_in(7.0, 0, 0, 0, 220)

	# When death sound finishes → decrement life and go to the correct world map
	player.death_sound.finished.connect(func():
		InputManager.input_disabled = false
		get_tree().paused = false
		player.process_mode = player.PROCESS_MODE_INHERIT
		var lives = int(SaveManager.runtime_data.get("lives", 3))
		SaveManager.runtime_data["lives"] = max(0, lives - 1)
		SaveManager.commit_runtime_to_save(save_index)

		if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
			SaveManager.hud.update_labels()

		var world_number = int(SaveManager.runtime_data.get("world_number", 1))
		var map_path = "res://Scenes/WorldMaps/World%d.tscn" % world_number
		if ResourceLoader.exists(map_path):
			get_tree().change_scene_to_file(map_path)
		else:
			push_error("World map not found: %s" % map_path)
	)
