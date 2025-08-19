extends Node2D

var character_index := -1
var save_index := -1

@onready var audio_streamer: AudioStreamPlayer2D = $AudioStreamer

func _ready():
	if audio_streamer and not audio_streamer.playing:
		audio_streamer.play()

	if save_index >= 0 and character_index >= 0:
		var save_data := {
			"character_index": character_index,
			"world_number": 1
		}
