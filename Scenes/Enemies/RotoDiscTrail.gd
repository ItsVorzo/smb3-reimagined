extends AnimatedSprite2D

var trail_positions := []
@export var trail_length := 3
@export var trail_spacing := 0.08
var timer := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(timer)
	timer -= delta
	if timer <= 0:
		trail_positions.append(global_position)
		if trail_positions.size() > trail_length:
			trail_positions.pop_front()
		timer = trail_spacing

	if GameManager.is_on_screen(global_position):
		queue_redraw()

func _draw():
	var tex = sprite_frames.get_frame_texture(animation, frame)
	var sproffset = tex.get_size() / -2

	for i in range(trail_positions.size()):
		var pos = trail_positions[i]
		var alpha = float(i) / trail_positions.size()
		draw_texture(tex, (pos - global_position) + sproffset, Color(1, 1, 1, alpha))
