extends Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var coin_sound = $AudioStreamPlayer2D
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	anim_sprite.play("idle")
	coin_sound.play()
	animation_player.play("collect")
	animation_player.animation_finished.connect(_on_collect_animation_finished)
	var tween = create_tween()
	tween.tween_property(self, "position.y", position.y - 48, 0.6)
	
func _on_collect_animation_finished(anim_name: String) -> void:
	if anim_name == "collect":
		queue_free()
