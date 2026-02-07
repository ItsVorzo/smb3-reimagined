extends Node2D

@export var world_number: int = 1

var character_index := -1
var save_index := -1

@onready var audio_streamer: AudioStreamPlayer2D = $AudioStreamer

func _ready():
	TransitionManager.fade_out(6.0)

	if audio_streamer and not audio_streamer.playing:
		audio_streamer.play()

	# Update save data when arriving from a level
	if save_index >= 0 and character_index >= 0:
		SaveManager.runtime_data["character_index"] = character_index
		SaveManager.runtime_data["world_number"] = world_number
