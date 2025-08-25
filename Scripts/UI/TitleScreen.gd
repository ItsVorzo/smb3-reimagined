extends Node2D

@onready var music = $TitleMusic
@onready var select = $Select
@onready var movesfx = $Move
@onready var opt1 = $StoryMode
@onready var opt2 = $Options
@onready var leftsqr = $LeftSquare
@onready var rightsqr = $RightSquare

var labels = []
var highlight_c = Color("#ffaa47")
var normal_c = Color.WHITE
var animation_played := false
var sprite_deleted := false

# Scenes
var SelectFileScene = preload("res://Scenes/UI/gamemode_select.tscn")
var OptionsScene = preload("res://Scenes/UI/options.tscn")
var CharacterSelectScene = preload("res://Scenes/UI/CharacterSelect.tscn") # Only if needed

# Instances
var select_file_instance: Node = null
var options_instance: Node = null
var char_select_instance: Node = null

# Selection
var h_select := 1

func _ready() -> void:
	labels = [opt1, opt2]
	update_selection()

func _process(_delta):
	# Block title screen input if any sub-menu is open
	if _is_submenu_open():
		return

	if InputManager.Apress and not animation_played:
		$Curtain/AnimationPlayer.play("rise")
		music.play()
		animation_played = true
		update_selection()

	if InputManager.Apress and not sprite_deleted:
		var sprite = get_node_or_null("PressSpace")
		if sprite:
			sprite.queue_free()
			sprite_deleted = true

	if animation_played:
		if InputManager.left_press:
			h_select = wrap(h_select - 1, 1, labels.size() + 1)
			update_selection()
		if InputManager.right_press:
			h_select = wrap(h_select + 1, 1, labels.size() + 1)
			update_selection()

		if not $Curtain/AnimationPlayer.is_playing() and not _is_submenu_open():
			if InputManager.Apress:
				match h_select:
					1:
						story_mode()
					2:
						open_options()

func _is_submenu_open() -> bool:
	return (
		(select_file_instance != null and is_instance_valid(select_file_instance)) or
		(options_instance != null and is_instance_valid(options_instance)) or
		(char_select_instance != null and is_instance_valid(char_select_instance))
	)

func update_selection():
	for i in range(labels.size()):
		labels[i].add_theme_color_override(
			"font_color", 
			highlight_c if h_select == i + 1 else normal_c
		)

	var selected_opt = labels[h_select - 1]
	var select_pos = selected_opt.global_position
	leftsqr.show()
	rightsqr.show()
	leftsqr.global_position = select_pos + Vector2(-selected_opt.size.x / 6, 4)
	rightsqr.global_position = select_pos + Vector2(selected_opt.size.x / 0.86, 4)

	SoundManager.play_sfx("MapMove", global_position)

func story_mode() -> void:
	if select_file_instance == null or not is_instance_valid(select_file_instance):
		SoundManager.play_sfx("Inventory", global_position)
		select_file_instance = SelectFileScene.instantiate()
		add_child(select_file_instance)
	else:
		print("Stop spamming u gimp")

func open_options() -> void:
	SoundManager.play_sfx("Inventory", global_position)
	if options_instance == null or not is_instance_valid(options_instance):
		options_instance = OptionsScene.instantiate()
		add_child(options_instance)
	else:
		print("poopyhead")
