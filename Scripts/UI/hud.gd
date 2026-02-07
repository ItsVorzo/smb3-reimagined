extends CanvasLayer

@onready var player_icon: AnimatedSprite2D = $HUD_BG/PlayerIcon
@onready var world_label: Label = $HUD_BG/WorldNumber
@onready var score_label: Label = $HUD_BG/Score
@onready var coins_label: Label = $HUD_BG/CoinCounter
@onready var time_label: Label = $HUD_BG/Time
@onready var lives_label: Label = $HUD_BG/LifeCounter
@onready var course_clear_label: Label = $CourseClearLabel
@onready var card_label: Label = $CardLabel
@onready var card_sprite: AnimatedSprite2D = $CardLabel/CardSprite
@onready var card_slot_1: AnimatedSprite2D = $HUD_BG/CardSlot1
@onready var card_slot_2: AnimatedSprite2D = $HUD_BG/CardSlot2
@onready var card_slot_3: AnimatedSprite2D = $HUD_BG/CardSlot3
@onready var finishtime_label: Label = $FinishTimeLabel
@onready var finishtime_icon: Sprite2D = $FinishTime
@onready var finishscore_label: Label = $FinishScoreLabel
@onready var multiplier_label: Label = $MultiplierLabel
# Markiplier

enum ScreenMode { FOUR_THREE, EXTENDED }
var screen_mode: ScreenMode

var time_timer: Timer
var time_running := true
var card_blink_active := false

func update_labels():
	var save_data = SaveManager.runtime_data
	var temp_data = SaveManager.temp_level_data
	
	player_icon.frame = int(save_data.get("character_index", 0))
	world_label.text = str(int(save_data.get("world_number", 1)))
	coins_label.text = str(int(save_data.get("coins", 0))).pad_zeros(2)
	score_label.text = str(int(save_data.get("score", 0))).pad_zeros(7)
	time_label.text = str(int(temp_data.get("time", 300))).pad_zeros(3)
	lives_label.text = str(int(save_data.get("lives", 3))).pad_zeros(2)

func _ready():
	update_labels()
	update_card_slots()
	time_timer = Timer.new()
	time_timer.wait_time = 0.68
	time_timer.one_shot = false
	time_timer.autostart = true
	add_child(time_timer)
	time_timer.timeout.connect(_on_time_timer_timeout)
	

func _on_time_timer_timeout():
	if not time_running:
		return
	var current_time = int(SaveManager.get_temp("time", 300))
	if current_time > 0:
		SaveManager.set_temp("time", current_time - 1)
		update_labels()

# === Time Control ===
func pause_time():
	time_running = false

func resume_time():
	time_running = true

# === Level Complete Messages ===
func show_course_clear():
	course_clear_label.text = "course clear !"
	course_clear_label.visible = true

func show_card_message(card_type: String, is_match: bool = false):
	var card_name = card_type.to_lower()
	var aspect_ratio = ConfigManager.option_indices["Size"]
	if card_type == "FireFlower":
		card_name = "flower"
	if is_match:
		card_label.text = "you got match of " + card_name + " cards"
	else:
		card_label.text = "you got a " + card_name + " card"
	
	# Set position based on match type
	if is_match:
		card_label.position = Vector2(center_x(-93), 165)
		match aspect_ratio:
			0: # 4:3
				card_sprite.position = Vector2(center_x(92), -14)
			1: # Extended
				card_sprite.position = Vector2(center_x(7), -14)
	else:
		card_label.position = Vector2(center_x(-94), 47)
		match aspect_ratio:
			0: # 4:3
				card_sprite.position = Vector2(center_x(36), -14)
			1: # Extended
				card_sprite.position = Vector2(center_x(-49), -14)
	
	card_label.visible = true
	card_sprite.play(card_type)

func show_finish_score(is_match: bool = false):
	if is_match:
		finishscore_label.position = Vector2(center_x(57)-39, 24)
		finishtime_label.position = Vector2(center_x(-15)-39, 24)
		finishtime_icon.position = Vector2(center_x(-19)-39, 28)
		multiplier_label.position = Vector2(center_x(10)-39, 24)
	else:
		finishscore_label.position = Vector2(center_x(57)-39, 70)
		finishtime_label.position = Vector2(center_x(-15)-39, 70)
		finishtime_icon.position = Vector2(center_x(-19)-39, 74)
		multiplier_label.position = Vector2(center_x(10)-39, 70)

	multiplier_label.text = "# 50="

	update_finish_score_from_time()

	finishscore_label.visible = true
	finishtime_label.visible = true
	finishtime_icon.visible = true
	multiplier_label.visible = true

func update_finish_score_from_time():
	var level_time := int(SaveManager.get_temp("time", 0))
	
	finishtime_label.text = str(level_time).pad_zeros(3)
	
	var score := level_time * 50
	finishscore_label.text = str(score).pad_zeros(5)
	
# === Card System ===
func update_card_slots():
	var cards = SaveManager.runtime_data.get("goal_items", [])
	
	# Update each slot based on saved cards
	if cards.size() >= 1:
		card_slot_1.animation = cards[0]
		card_slot_1.play()
	else:
		card_slot_1.animation = "Empty"
	
	if cards.size() >= 2:
		card_slot_2.animation = cards[1]
		card_slot_2.play()
	else:
		card_slot_2.animation = "Empty"
	
	if cards.size() >= 3:
		card_slot_3.animation = cards[2]
		card_slot_3.play()
	else:
		card_slot_3.animation = "Empty"

func start_card_blink_infinite(slot_index: int, item: String):
	card_blink_active = true
	var slot: AnimatedSprite2D
	match slot_index:
		0: slot = card_slot_1
		1: slot = card_slot_2
		2: slot = card_slot_3
	
	while card_blink_active:
		slot.animation = "Empty"
		await get_tree().create_timer(0.3).timeout
		if not card_blink_active: break
		slot.animation = item
		await get_tree().create_timer(0.3).timeout

func start_all_cards_cascade_blink():
	if card_blink_active:
		return
	
	card_blink_active = true
	var cards = SaveManager.runtime_data.get("goal_items", [])
	if cards.size() != 3:
		return
	
	# Initial state (matches SMB3 feel)
	card_slot_1.animation = "Empty"
	card_slot_2.animation = cards[1]
	card_slot_3.animation = "Empty"
	
	await get_tree().create_timer(0.15).timeout
	
	while card_blink_active:
		# Phase 1: outer cards ON
		card_slot_1.animation = cards[0]
		card_slot_3.animation = cards[2]
		await get_tree().create_timer(0.12).timeout
		if not card_blink_active: break
		
		# Phase 2: center OFF
		card_slot_2.animation = "Empty"
		await get_tree().create_timer(0.12).timeout
		if not card_blink_active: break
		
		# Phase 3: reset
		card_slot_1.animation = "Empty"
		card_slot_2.animation = cards[1]
		card_slot_3.animation = "Empty"
		await get_tree().create_timer(0.20).timeout

func stop_card_blink():
	card_blink_active = false
	update_card_slots()

func center_x(offset := 0) -> float:
	return get_viewport().get_visible_rect().size.x / 2 + offset
