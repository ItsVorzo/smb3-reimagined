extends Node2D

@onready var music = $TitleMusic
@onready var select = $Select
@onready var movesfx = $Move
@onready var option1 = $SinglePlayer
@onready var option2 = $TextureButton
@onready var opt1 = $StoryMode
@onready var opt2 = $Options
@onready var leftsqr = $LeftSquare
@onready var rightsqr = $RightSquare

var labels = []
var highlight_c = Color("#ffaa47")
var normal_c = Color.WHITE
var animation_played := false
var sprite_deleted := false
var SelectFileScene = preload("res://Scenes/UI/select_file.tscn")
var select_file_instance: Node = null

var h_select := 1

func _ready() -> void:
	labels = [opt1, opt2]

func _process(_delta):
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

	if !$Curtain/AnimationPlayer.is_playing():
		match(h_select):
			1:
				if InputManager.Apress:
					story_mode()

func update_selection():
	# Change the text color
	for i in range(labels.size()):
		labels[i].add_theme_color_override("font_color", highlight_c if h_select == i + 1 else normal_c)

	# Square thingieees
	var selected_opt = labels[h_select - 1] # Which option is currently selected
	var select_pos = selected_opt.global_position # The position of the selected option
	leftsqr.show()
	rightsqr.show()

	leftsqr.global_position = select_pos + Vector2(-selected_opt.size.x / 6, 4)
	rightsqr.global_position = select_pos + Vector2(selected_opt.size.x / 0.86, 4)

	movesfx.play()

func story_mode() -> void:
	if select_file_instance == null or not is_instance_valid(select_file_instance):
		select.play()
		select_file_instance = SelectFileScene.instantiate()
		add_child(select_file_instance)
	else:
		print("Stop spamming u gimp")
