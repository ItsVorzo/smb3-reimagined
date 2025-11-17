extends ColorRect

# === Fade transitions ===
var fade_delay := 10
var fade_color: Color
var is_fading := false
var fading_to_scene := false
var scene_path = null
var fade_speed: float = 1.0
var fade_timer: float = 0.0
enum fade_list {
	fade_in = 1,
	fade_out = -1,
	fade_none = 0
}
var fade_type := 0
var screen_size: Vector2

var r: int
var g: int
var b: int

func _ready() -> void:
	is_fading = false
	fading_to_scene = false
	screen_size = get_viewport().get_visible_rect().size

func _physics_process(_delta: float) -> void:
	screen_size = get_viewport().get_visible_rect().size
	# Stop if you aren't transitioning
	if not is_fading:
		fade_timer = 0.0
		return

	# Check wether the transition is done
	if fade_type == -1 and fade_timer == 0 or fade_type == 1 and fade_timer == 512:
		is_fading = false
	if fade_type == 1 and fade_timer == 255 and fading_to_scene:
		fading_to_scene = false
		get_tree().change_scene_to_file(scene_path)
	# Decrease delay timer
	if fade_delay > 0:
		fade_delay -= 1

	# Decrease/increase fading state
	if fade_delay == 0:
		fade_timer += (fade_speed * (255.0/100.0)) * fade_type
	fade_timer = clamp(fade_timer, 0, 255.0)

	queue_redraw() # Update _draw()

func _draw():
	fade_color = Color.from_rgba8(r, g, b, fade_timer)
	draw_rect(Rect2(Vector2.ZERO, screen_size), fade_color, true)
