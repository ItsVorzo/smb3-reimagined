extends CanvasLayer

@onready var player_icon: AnimatedSprite2D = $HUD_BG/PlayerIcon
@onready var world_label: Label = $HUD_BG/WorldLabel
@onready var score_label: Label = $HUD_BG/ScoreLabel
@onready var coins_label: Label = $HUD_BG/CoinLabel
@onready var time_label: Label = $HUD_BG/TimeLabel
@onready var lives_label: Label = $HUD_BG/LivesLabel
@onready var Plr = $"../Player"

var time_timer: Timer
var time_running := true   # <--- NEW FLAG

func update_labels():
	var save_data = SaveManager.runtime_data
	var temp_data = SaveManager.temp_level_data

	
	player_icon.frame = int(save_data.get("character_index", 0))
	world_label.text = str(int(save_data.get("world_number", 1)))
	coins_label.text = str(int(save_data.get("coins", 0))).pad_zeros(2)
	score_label.text = str(int(save_data.get("score", 0))).pad_zeros(7)
	time_label.text = str(int(temp_data.get("time", 300)))  # <-- use temp save
	lives_label.text = str(int(save_data.get("lives", 3))).pad_zeros(2)

func _ready():
	update_labels()
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

# === New API ===
func pause_time():
	time_running = false

func resume_time():
	time_running = true
