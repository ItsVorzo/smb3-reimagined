extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var bd_sprite = $BD
@onready var select_sound = $Select
@onready var move_sound = $Move
@onready var back_sound = $BackSound
@onready var delete_save_sound = $DeleteSave

@onready var save_buttons := [
	$HBoxContainer/SaveSlot0,
	$HBoxContainer/SaveSlot1,
	$HBoxContainer/SaveSlot2,
	$HBoxContainer/SaveSlot3,
	$HBoxContainer/SaveSlot4
]

@onready var copy_button := $HBoxContainer2/CopyButton
@onready var delete_button := $HBoxContainer2/DeleteButton

var save_mode: String = "select"  # Modes: "select", "copy", "delete", "copy_dest"
var selected_copy_index: int = -1

const BUTTON_WIDTH := 151
const BUTTON_HEIGHT := 23
const H_SPACING := 2
const V_SPACING := 1

func _ready() -> void:
	bd_sprite.play("select")
	update_save_buttons()
	
	for i in save_buttons.size():
		save_buttons[i].connect("pressed", Callable(self, "_on_save_slot_pressed").bind(i))

	copy_button.connect("pressed", _on_copy_pressed)
	delete_button.connect("pressed", _on_delete_pressed)

func update_save_buttons():
	for i in range(save_buttons.size()):
		var save_data = SaveManager.load_game(i)
		var button = save_buttons[i]
		
		# Set texture depending on save empty/full
		if save_data.is_empty():
			button.texture_normal = get_file_slot_texture(1, 0)
			button.texture_hover = get_file_slot_texture(1, 1)
		else:
			button.texture_normal = get_file_slot_texture(0, 0)
			button.texture_hover = get_file_slot_texture(0, 1)

		# Character icon
		var char_icon = button.get_node_or_null("CharacterIcon")
		if char_icon:
			char_icon.visible = not save_data.is_empty()
			if not save_data.is_empty():
				char_icon.frame = int(save_data.get("character_index", 0))
				char_icon.pause()

		# World label
		var world_label = button.get_node_or_null("World")
		if world_label:
			if save_data.is_empty():
				world_label.text = ""
			else:
				world_label.text = str(int(save_data.get("world_number", 1)))

		# Lives label
		var lives_label = button.get_node_or_null("Lives")
		if lives_label:
			if save_data.is_empty():
				lives_label.text = ""
			else:
				var lives = int(save_data.get("lives", 3))
				lives_label.text = str(lives).pad_zeros(2)

func get_file_slot_texture(col: int, row: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://Sprites/Title Screen/File Select/FileSelectSaves.png")
	atlas.region = Rect2(
		col * (BUTTON_WIDTH + H_SPACING),
		row * (BUTTON_HEIGHT + V_SPACING),
		BUTTON_WIDTH,
		BUTTON_HEIGHT
	)
	return atlas

func _on_save_slot_pressed(index: int):
	match save_mode:
		"select":
			handle_slot_select(index)
		"delete":
			handle_delete(index)
		"copy":
			selected_copy_index = index
			save_mode = "copy_dest"
			bd_sprite.play("select")
		"copy_dest":
			handle_copy(selected_copy_index, index)
			save_mode = "select"
			bd_sprite.play("select")

func handle_slot_select(index: int):
	var save_data = SaveManager.load_game(index)
	show_character_select(index)

func handle_delete(index: int):
	SaveManager.delete_save(index)
	delete_save_sound.play()
	update_save_buttons()
	save_mode = "select"
	bd_sprite.play("select")

func handle_copy(from_index: int, to_index: int):
	if from_index != to_index:
		SaveManager.copy_save(from_index, to_index)
		update_save_buttons()

func _on_copy_pressed():
	save_mode = "copy"
	select_sound.play()
	bd_sprite.play("copy")

func _on_delete_pressed():
	save_mode = "delete"
	select_sound.play()
	bd_sprite.play("delete")

func _process(_delta: float) -> void:
	if InputManager.Bpress: _on_back_pressed()

func _on_back_pressed() -> void:
	back_sound.play()
	animation_player.play("close")
	await get_tree().create_timer(0.2).timeout
	queue_free()

# --- New function to load Character Select screen ---
func show_character_select(save_index: int):
	var character_select_scene = preload("res://Scenes/UI/character_select.tscn").instantiate()
	character_select_scene.save_index = save_index
	get_tree().root.add_child(character_select_scene)
	queue_free()  # Close this screen
