extends Node2D

@onready var animation_player = $AnimationPlayer

func _on_back_pressed() -> void:
	animation_player.play("close")  # Play your closing animation
	await get_tree().create_timer(0.2).timeout  # Wait 0.2 seconds
	queue_free()  # Now delete the scene
