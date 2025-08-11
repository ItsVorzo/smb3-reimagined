extends Node2D

@onready var select_char_sound = $Select
@onready var move_char_sound = $Move
@onready var cancel_char_sound = $Back
@onready var animation_player = $AnimationPlayer

@onready var select_boxes := {
	1: $CharacterSelectBox/CharSelectBoxP1,
	2: $CharacterSelectBox/CharSelectBoxP2,
	3: $CharacterSelectBox/CharSelectBoxP3,
	4: $CharacterSelectBox/CharSelectBoxP4
}

@onready var player_boxes := {
	1: $PlayerIndicator/CharPlayerBoxP1,
	2: $PlayerIndicator/CharPlayerBoxP2,
	3: $PlayerIndicator/CharPlayerBoxP3,
	4: $PlayerIndicator/CharPlayerBoxP4
}

@onready var nameplate_boxes := {
	1: $NamePlates/CharNameplateP1
}

@onready var player1_sprite: AnimatedSprite2D = $Characters/Player1

# --- State ---
var is_player1_active: bool = false
var is_player1_selected: bool = false
var player1_character_index: int = 0
var total_characters: int = 4
var save_index: int = -1

var character_select_timer: SceneTreeTimer = null
var timer_cancelled: bool = false

# --- Setup ---
func _ready() -> void:
	select_char_sound.play()
	for i in select_boxes:
		select_boxes[i].play("none")
	for i in player_boxes:
		player_boxes[i].play("none")
		player_boxes[i].frame = 0
	for i in nameplate_boxes:
		nameplate_boxes[i].play("none")

	player1_sprite.visible = true
	player1_sprite.animation = "connect"
	player1_sprite.frame = 0
	player1_sprite.play()

	nameplate_boxes[1].animation = "connect"
	nameplate_boxes[1].play()

# --- Input Handling ---
func _process(_delta: float) -> void:
	if !is_player1_active and Input.is_action_just_pressed("jump"):
		select_char_sound.play()
		activate_player1()

	elif is_player1_active and !is_player1_selected:
		if Input.is_action_just_pressed("move_left"):
			move_char_sound.play()
			player1_character_index = (player1_character_index - 1 + total_characters) % total_characters
			update_character_sprite()

		elif Input.is_action_just_pressed("move_right"):
			move_char_sound.play()
			player1_character_index = (player1_character_index + 1) % total_characters
			update_character_sprite()

		elif Input.is_action_just_pressed("jump"):
			select_char_sound.play()
			confirm_character()

	elif is_player1_selected:
		if Input.is_action_just_pressed("run"):
			cancel_char_sound.play()
			cancel_selection()

# --- Activation ---
func activate_player1():
	is_player1_active = true
	select_boxes[1].play("selecting")
	
	player_boxes[1].animation = "selecting_p1"
	player_boxes[1].frame = player1_character_index
	player_boxes[1].pause()
	
	nameplate_boxes[1].animation = "selecting"
	nameplate_boxes[1].frame = player1_character_index
	nameplate_boxes[1].pause()
	
	update_character_sprite()

# --- Character Update ---
func update_character_sprite():
	player1_sprite.animation = "selecting"
	player1_sprite.frame = player1_character_index
	player1_sprite.pause()

	var box = player_boxes[1]
	box.play("selecting_p1")
	box.frame = player1_character_index
	box.pause()
	
	var nameplate = nameplate_boxes[1]
	nameplate.animation = "selecting"
	nameplate.frame = player1_character_index
	nameplate.pause()

func confirm_character():
	character_select_timer = null
	timer_cancelled = false
	is_player1_selected = true

	select_boxes[1].play("selected")
	player_boxes[1].play("selected_p1")
	player_boxes[1].frame = player1_character_index
	player_boxes[1].pause()

	player1_sprite.animation = "selected"
	player1_sprite.frame = player1_character_index
	player1_sprite.pause()

	var existing_data = SaveManager.load_game(save_index)
	var save_data := {}

	if existing_data.is_empty():
		save_data = {
			"character_index": player1_character_index,
			"has_started_game": true,
			"world_number": 1,
			"lives": 3
		}
	else:
		save_data = existing_data.duplicate()
		save_data["character_index"] = player1_character_index
		save_data["has_started_game"] = true

	SaveManager.save_game(save_index, save_data)

	start_transition_to_world()

func cancel_selection():
	is_player1_selected = false
	timer_cancelled = true

	select_boxes[1].play("selecting")
	player_boxes[1].animation = "selecting_p1"
	player_boxes[1].frame = player1_character_index
	player_boxes[1].pause()

	player1_sprite.animation = "selecting"
	player1_sprite.frame = player1_character_index
	player1_sprite.pause()

	character_select_timer = null

func start_transition_to_world():
	if character_select_timer and is_instance_valid(character_select_timer):
		character_select_timer = null

	timer_cancelled = false
	character_select_timer = get_tree().create_timer(3.0)
	var local_timer = character_select_timer

	await local_timer.timeout

	if timer_cancelled or local_timer != character_select_timer:
		return

	var save_data := SaveManager.load_game(save_index)
	var world_number: int = int(save_data.get("world_number", 1))  # Ensure int type

	var world_scene_path := "res://Scenes/WorldMaps/world_%d.tscn" % world_number
	get_tree().change_scene_to_file(world_scene_path)
	queue_free()

func _on_back_button_pressed() -> void:
	cancel_char_sound.play()
	animation_player.play("close")
	await get_tree().create_timer(0.2).timeout
	queue_free()
