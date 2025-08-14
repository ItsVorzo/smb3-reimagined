extends Node2D
@onready var startscreen = $AudioStreamPlayer

func _input(_event):
	if InputManager.any:
		get_tree().change_scene_to_file("res://Scenes/UI/title_screen.tscn")
