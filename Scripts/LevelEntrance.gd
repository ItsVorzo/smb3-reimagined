extends Area2D

@export var level_scene_path: String
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var animation_name: String = "start"
@onready var enter_level_sound: AudioStreamPlayer2D = $EnterLevelSound

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

		# Get the root of the current scene
		var world_root = get_tree().current_scene

		# If AudioStreamer exists directly under root, pause it
		if world_root.has_node("AudioStreamer"):
			var audio_streamer: AudioStreamPlayer2D = world_root.get_node("AudioStreamer") as AudioStreamPlayer2D
			if audio_streamer.playing:
				audio_streamer.stop()

		# Play level enter sound
		SoundManager.play_sfx("MapStart")
		await get_tree().create_timer(1.11).timeout  # wait until sound finishes

		# Change scene after sound finishes
		InputManager.input_disabled = false
		if level_scene_path != "":
			get_tree().change_scene_to_file(level_scene_path)
