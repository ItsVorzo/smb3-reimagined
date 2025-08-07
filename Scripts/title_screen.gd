extends Node2D

@onready var music = $AudioStreamPlayer2D

var animation_played := false
var sprite_deleted := false
var SelectFileScene = preload("res://Scenes/UI/select_file.tscn")
var select_file_instance: Node = null

func _input(_event):
	if Input.is_action_pressed("ui_accept") and not animation_played:
		$Curtain/AnimationPlayer.play("rise")
		music.play()
		animation_played = true
	if Input.is_action_pressed("ui_accept") and not sprite_deleted:
		var sprite = get_node_or_null("PressSpace")
		if sprite:
			sprite.queue_free()
			sprite_deleted = true
			
func _on_single_player_pressed() -> void:
	if select_file_instance == null or not is_instance_valid(select_file_instance):
		select_file_instance = SelectFileScene.instantiate()
		add_child(select_file_instance)
	else:
		print("Stop spamming u gimp")
