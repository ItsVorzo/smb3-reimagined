extends Node2D

@export_enum("Overworld", "Underground", "Desert", "Snow") var theme: String = "Overworld"

@onready var terrain_tilemap = $TerrainTileMap
@onready var semisolid_tilemap = $SemisolidTileMap
@onready var pipe_tilemap = $PipeTileMap
@onready var bgm = $Player/BGM

var save_index := 0  # Change if needed

func _ready() -> void:
	# Load runtime data
	SaveManager.start_runtime_from_save(save_index)
	
	# Store HUD globally for fast access
	SaveManager.hud = $HUD
	
	# Update HUD immediately
	SaveManager.hud.update_labels()
	
	# Apply level theme visuals & music
	apply_theme()
	
func apply_theme():
	# Terrain
	var terrain_path = "res://Sprites/Tilesets/%s/%s.tres" % [theme, theme]
	terrain_tilemap.tile_set = load(terrain_path)
	
	# Semisolid
	var semisolid_path = "res://Sprites/Tilesets/%s/Semisolid.tres" % theme
	semisolid_tilemap.tile_set = load(semisolid_path)
	
	# Pipe
	var pipe_path = ""
	if theme == "Overworld":
		pipe_path = "res://Sprites/Gizmos/Pipes.tres"
	else:
		pipe_path = "res://Sprites/Gizmos/Variants/%s/Pipes.tres" % theme
	pipe_tilemap.tile_set = load(pipe_path)
		
	# Music
	var music_path = "res://Audio/BGM/%s.ogg" % theme
	bgm.stream = load(music_path)
	bgm.play()
