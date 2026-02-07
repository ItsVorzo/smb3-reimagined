extends Node

var sfxlibrary := preload("res://Audio/Sfx/SfxLibrary.tres")

# Sounds that are allowed to overlap + their volume
var overlap_sfx := {
	"Text": -8.0,
	"CardMatch": -8.0
}

var audio_queue := {}

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func play_sfx(
	sfx_name: String = "",
	position: Vector2 = Vector2.ZERO,
	pitch_shift: float = 1.0
) -> void:
	if not sfxlibrary.sfx.has(sfx_name):
		return
	
	var allows_overlap := overlap_sfx.has(sfx_name)

	# Only prevent overlap for non-overlapping sounds
	if not allows_overlap and audio_queue.has(sfx_name):
		audio_queue[sfx_name].queue_free()
		audio_queue.erase(sfx_name)

	var audio_player := AudioStreamPlayer2D.new()
	audio_player.stream = sfxlibrary.sfx[sfx_name]
	audio_player.pitch_scale = pitch_shift
	audio_player.global_position = position
	audio_player.attenuation = 0.0
	audio_player.max_distance = 512
	audio_player.autoplay = true
	audio_player.set_process_mode(Node.PROCESS_MODE_ALWAYS)

	# Apply per-sound volume if defined
	if allows_overlap:
		audio_player.volume_db = overlap_sfx[sfx_name]

	get_tree().root.add_child(audio_player)

	if not allows_overlap:
		add_sound_to_queue(sfx_name, audio_player)

	await audio_player.finished
	audio_player.queue_free()

func add_sound_to_queue(sfx: String, audio_stream: AudioStreamPlayer2D) -> void:
	audio_queue[sfx] = audio_stream
	await audio_stream.finished
	audio_queue.erase(sfx)
