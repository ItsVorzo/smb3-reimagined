extends Area2D

@export var level_scene_path: String
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var animation_name: String = "start"

var player_inside := false

func _ready():
	sprite.play(animation_name)

func _on_body_entered(body):
	if body.is_in_group("Overworld"):
		player_inside = true
func _on_body_exited(body):
	if body.is_in_group("Overworld"):
		player_inside = false
func _process(delta):
	if player_inside and Input.is_action_just_pressed("jump"):
		if level_scene_path != "":
			get_tree().change_scene_to_file(level_scene_path)
