extends Node2D

var character_index := -1
var save_index := -1

func _ready():
	if save_index >= 0 and character_index >= 0:
		var save_data := {
			"character_index": character_index,
			"world_number": 2
		}
