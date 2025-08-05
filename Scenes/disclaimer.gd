extends Node2D

func _input(_event):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
