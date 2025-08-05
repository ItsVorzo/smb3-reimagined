extends Node2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var break_sound = $AudioStreamPlayer
var is_used = false

func hit_from_below():
	if is_used:
		return
	is_used = true
	break_sound.play()
	anim.play("bounce")
	# await anim.animation_finished <- Made as comment, as there's no actual animation yet lmao
	queue_free()
