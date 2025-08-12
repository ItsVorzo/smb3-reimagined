extends CanvasLayer

@onready var player_icon: AnimatedSprite2D = $HUD_BG/PlayerIcon
@onready var world_label: Label = $HUD_BG/WorldLabel
@onready var score_label: Label = $HUD_BG/ScoreLabel
@onready var coins_label: Label = $HUD_BG/CoinLabel
@onready var time_label: Label = $HUD_BG/TimeLabel
@onready var lives_label: Label = $HUD_BG/LivesLabel

var time_timer: Timer

func update_labels():
	var save_data = SaveManager.runtime_data

	# Player icon
	var char_index = int(save_data.get("character_index", 0))
	player_icon.frame = char_index

	# World number
	var world_number = int(save_data.get("world_number", 1))
	world_label.text = str(world_number)

	# Coins
	var coin_count = int(save_data.get("coins", 0))
	coins_label.text = str(coin_count).pad_zeros(2)

	# Score
	var score_value = int(save_data.get("score", 0))
	score_label.text = str(score_value).pad_zeros(7)

	# Time
	var time_left = int(save_data.get("time", 300))
	time_label.text = str(time_left)

	# Lives
	var lives_count = int(save_data.get("lives", 3))
	lives_label.text = str(lives_count).pad_zeros(2)

func _ready():
	update_labels()

	# Timer setup
	time_timer = Timer.new()
	time_timer.wait_time = 0.68
	time_timer.one_shot = false
	time_timer.autostart = true
	add_child(time_timer)
	time_timer.timeout.connect(_on_time_timer_timeout)

func _on_time_timer_timeout():
	var current_time = int(SaveManager.runtime_data.get("time", 300))
	if current_time > 0:
		SaveManager.runtime_data["time"] = current_time - 1
		update_labels()
