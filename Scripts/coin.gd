extends Node2D

@onready var anim_sprite = $AnimatedSprite2D
@onready var coin_sound = $AudioStreamPlayer2D

func _ready() -> void:
	anim_sprite.play("idle")
	coin_sound.play()
	var tween = create_tween()
	tween.tween_property(self, "position.y", position.y - 48, 0.6)
	tween.tween_interval(0.88)
	tween.tween_callback(Callable(self, "queue_free"))
