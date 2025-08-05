extends Node2D
@onready var startscreen = $AudioStreamPlayer

func _input(_event):
	startscreen.play()
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
