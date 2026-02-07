extends TextureRect

@onready var player_icon = $PlayerIcon
@onready var world_number = $WorldNumber
@onready var score = $Score
@onready var coin_counter = $CoinCounter
@onready var time = $Time
@onready var life_counter = $LifeCounter
@onready var card_slot1 = $CardSlot1
@onready var card_slot2 = $CardSlot2
@onready var card_slot3 = $CardSlot3
var hud := preload("res://Sprites/HUD/HUD.png")
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
	p_meter = GameManager.p_meter[0]
	# This is the timer used to flash the p icon
	if p_meter >= GameManager.p_meter_max: flash_timer += 1
	else: flash_timer = 0
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _draw():
	var aspect_ratio = ConfigManager.option_indices["Size"]

	# Change the HUD BG size and change the elements position
	match aspect_ratio:
		0: # 4:3
			player_icon.global_position = Vector2(24, 210.5)
			world_number.global_position = Vector2(48, 197.5)
			score.global_position = Vector2(64, 206)
			coin_counter.global_position = Vector2(144, 198)
			time.global_position = Vector2(136, 206)
			life_counter.global_position = Vector2(40, 206)
			card_slot1.global_position = Vector2(183, 206)
			card_slot2.global_position = Vector2(208, 206)
			card_slot3.global_position = Vector2(233, 206)
			draw_texture_rect_region(hud, Rect2(Vector2(0, 190), Vector2(765, 50)), Rect2(Vector2(510, 0), Vector2(765, 50)))
		1: # Extended
			player_icon.global_position = Vector2(24, 210.5)
			world_number.global_position = Vector2(48, 197.5)
			score.global_position = Vector2(64, 206)
			coin_counter.global_position = Vector2(253, 198)
			time.global_position = Vector2(245, 206)
			life_counter.global_position = Vector2(40, 206)
			card_slot1.global_position = Vector2(352, 206)
			card_slot2.global_position = Vector2(377, 206)
			card_slot3.global_position = Vector2(402, 206)
			draw_texture_rect_region(hud, Rect2(Vector2(0, 190), Vector2(426, 50)), Rect2(Vector2(0, 0), Vector2(425, 50)))

	p_meter_element()

func p_meter_element():
	# Calculate how many arrows are filled
	filled_arrows = round(p_meter / 60 * arrow_n)

	# Draw and color the arrows
	for i in range(arrow_n):
		var arrow_pos = Rect2(Vector2(64.1 + 8 * i, 199), Vector2(8, 7))
		var arrow_color = arrow_white if i < filled_arrows else arrow_black
		draw_texture_rect_region(hud, arrow_pos, arrow_color)

	# Draw and flash the p icon
	var p_pos = Rect2(Vector2(113.3, 199), Vector2(15, 7))
	var p_color = p_black
	if p_meter >= GameManager.p_meter_max and floor(flash_timer / 10) % 2 < 1:
		p_color = p_white
	else: p_color = p_black
	draw_texture_rect_region(hud, p_pos, p_color)
