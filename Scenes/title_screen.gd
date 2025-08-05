extends Node2D

@onready var music = $AudioStreamPlayer2D

var animation_played := false
var sprite_deleted := false

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
	get_tree().change_scene_to_file("res://Scenes/Levels/level.tscn")
