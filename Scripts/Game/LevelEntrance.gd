extends Area2D

@export var level_scene_path: String
@export var animation_name: String = "start"
@export var ball_offset_y := -40.0  # Optional offset if needed

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enter_level_sound: AudioStreamPlayer2D = $EnterLevelSound
@onready var level_transition_scene := preload("res://Scenes/UI/level_transition.tscn")

var player_inside := false
var level_transition_started := false

func _ready():
	sprite.play(animation_name)

func _on_body_entered(body):
	if body.is_in_group("Overworld"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("Overworld"):
		player_inside = false

func _process(_delta):
	if player_inside and InputManager.Apress and not level_transition_started:
		InputManager.input_disabled = true
		level_transition_started = true

		var world_root = get_tree().current_scene

		# Stop overworld music if it's playing
		if world_root.has_node("AudioStreamer"):
			var audio_streamer: AudioStreamPlayer2D = world_root.get_node("AudioStreamer")
			if audio_streamer.playing:
				audio_streamer.stop()

		# Play the level enter sound
		SoundManager.play_sfx("MapStart")

		# Spawn the level transition scene (like a fade)
		var transition_instance = level_transition_scene.instantiate()
		world_root.add_child(transition_instance)

		# Wait for sound to finish (adjust time to match your audio)
		await get_tree().create_timer(1.11).timeout

		# Smoother transition fix i think?
		TransitionManager.fade_out(0, 0, 0, 0, 30)
		await get_tree().create_timer(0.2).timeout

		InputManager.input_disabled = false

		# Load the new level
		if level_scene_path != "":
			get_tree().change_scene_to_file(level_scene_path)
