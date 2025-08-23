extends Node2D


var SelectFileScene = preload("res://Scenes/UI/SelectFile.tscn")
 
func _on_singleplayer_b_pressed() -> void:
	var select_file_instance = SelectFileScene.instantiate()
	get_tree().current_scene.add_child(select_file_instance)  # Or `add_child()` if running from main
	
	# Free the current scene (e.g. gamemode_select.tscn)
	self.queue_free()
