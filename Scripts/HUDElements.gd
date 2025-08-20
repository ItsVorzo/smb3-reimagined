extends TextureRect

@onready var hudplr = get_parent() # Reference the player from the HUD node
var p_meter_hud := preload("res://Sprites/HUD/HUD.png")
var p_meter: float = 0.0
var arrow_n = 6
var filled_arrows
var arrow_black = Rect2(Vector2(240, 90), Vector2(8, 7))
var arrow_white = Rect2(Vector2(240, 99), Vector2(8, 7))
var p_black = Rect2(Vector2(250, 90), Vector2(15, 7))
var p_white = Rect2(Vector2(250, 99), Vector2(15, 7))
var flash_timer: int

func _process(_delta: float) -> void:
	# Get the p meter
	if is_instance_valid(hudplr.Plr): p_meter = hudplr.Plr.p_meter
	# This is the timer used to flash the p icon
	if p_meter >= hudplr.Plr.p_meter_max: flash_timer += 1
	else: flash_timer = 0
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _draw():
	# Calculate how many arrows are filled
	filled_arrows = round(p_meter / 60 * arrow_n)

	# Draw and color the arrows
	for i in range(arrow_n):
		var arrow_pos = Rect2(Vector2(57 + 8 * i, 12), Vector2(8, 7))
		var arrow_color = arrow_white if i < filled_arrows else arrow_black
		draw_texture_rect_region(p_meter_hud, arrow_pos, arrow_color)

	# Draw and flash the p icon
	var p_pos = Rect2(Vector2(106.5, 12), Vector2(15, 7))
	var p_color = p_black
	if p_meter >= hudplr.Plr.p_meter_max and floor(flash_timer / 10) % 2 < 1:
		p_color = p_white
	else: p_color = p_black
	draw_texture_rect_region(p_meter_hud, p_pos, p_color)
