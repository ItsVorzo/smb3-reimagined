extends Node

var sfxlibrary := preload("res://Audio/Sfx/SfxLibrary.tres")

var audio_queue := {}

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func play_sfx(sfx_name = "", position := Vector2.ZERO, pitch_shift := 1.0) -> void:
	if audio_queue.has(sfx_name):
		audio_queue[sfx_name].queue_free()
		audio_queue.erase(sfx_name)
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.pitch_scale = pitch_shift
	audio_player.global_position = position
	audio_player.attenuation = 0.0
	audio_player.stream = sfxlibrary.sfx[sfx_name]
	audio_player.autoplay = true
	audio_player.max_distance = 512
	audio_player.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	get_tree().root.add_child(audio_player)
	add_sound_to_queue(sfx_name, audio_player)
	await audio_player.finished
	audio_player.queue_free()

func add_sound_to_queue(sfx := "", audio_stream = null) -> void:
	if audio_stream == null:
		return
	audio_queue[sfx] = audio_stream
	await audio_stream.finished
	audio_queue.erase(sfx)
