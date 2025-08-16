extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var back_sound = $BackSound
@onready var switch_tab_sound = $SwitchTabs
@onready var change_option_sound = $ChangeOption

@onready var tabs: Dictionary = {
	"Display": $Tabs/Display,
	"Audio": $Tabs/Audio,
	"Gameplay": $Tabs/Gameplay,
	"Moveset": $Tabs/Moveset,
	"Sprites": $Tabs/Sprites
}

@onready var panels: Dictionary = {
	"Display": $Options/Display,
	"Audio": $Options/Audio,
	"Gameplay": $Options/Gameplay,
	"Moveset": $Options/Moveset,
	"Sprites": $Options/Sprites
}

@onready var current_tab_label = $CurrentTab

var first_tab_open: bool = true

func _ready() -> void:
	_apply_options()

	for name in tabs.keys():
		tabs[name].connect("pressed", Callable(self, "_on_tab_selected").bind(name))

	# --- Connect option value buttons ---
	_connect_value_button($Options/Display/ModeValueButton, "Mode")
	_connect_value_button($Options/Display/VSyncValueButton, "VSync")
	_connect_value_button($Options/Display/SizeValueButton, "Size")
	_connect_value_button($Options/Display/DropShadowValueButton, "DropShadows")
	_connect_value_button($Options/Gameplay/CameraModeValueButton, "CameraMode")

	# --- Remove focus outlines ---
	for btn in [
		$Options/Display/ModeValueButton,
		$Options/Display/VSyncValueButton,
		$Options/Display/SizeValueButton,
		$Options/Display/DropShadowValueButton,
		$Options/Gameplay/CameraModeValueButton
	]:
		btn.focus_mode = Control.FOCUS_NONE

	# --- Set labels from loaded config ---
	for option_name in ConfigManager.option_values.keys():
		var idx: int = ConfigManager.option_indices[option_name]
		_set_option_text(option_name, ConfigManager.option_values[option_name][idx])

	# Show default tab
	_on_tab_selected("Display", false)


func _connect_value_button(button: Button, option_name: String) -> void:
	button.pressed.connect(func(): _on_option_clicked(option_name))


func _on_tab_selected(tab_name: String, play_sound := true) -> void:
	if not first_tab_open and play_sound:
		switch_tab_sound.play()
	first_tab_open = false

	for panel in panels.values():
		panel.visible = false
	panels[tab_name].visible = true

	current_tab_label.text = tab_name.to_lower()
	print("Switched to tab:", tab_name)


func _on_option_clicked(option_name: String) -> void:
	change_option_sound.play()
	var values: Array = ConfigManager.option_values[option_name]
	var idx: int = (ConfigManager.option_indices[option_name] + 1) % values.size()
	
	# --- Save new value through ConfigManager ---
	ConfigManager.set_option(option_name, idx)

	var new_value: String = values[idx]
	_set_option_text(option_name, new_value)

	if option_name in ["Mode", "VSync"]:
		_apply_options()

	print(option_name, "changed to", new_value)


func _set_option_text(option_name: String, text: String) -> void:
	match option_name:
		"Mode":
			$Options/Display/ModeValueButton/ModeValue.text = text
		"VSync":
			$Options/Display/VSyncValueButton/VSyncValue.text = text
		"Size":
			$Options/Display/SizeValueButton/SizeValue.text = text
		"DropShadows":
			$Options/Display/DropShadowValueButton/DropShadowValue.text = text
		"CameraMode":
			$Options/Gameplay/CameraModeValueButton/CameraModeValue.text = text


func _on_back_pressed() -> void:
	back_sound.play()
	animation_player.play("close")
	await get_tree().create_timer(0.2).timeout
	queue_free()


func _apply_options() -> void:
	# --- Apply Mode ---
	match ConfigManager.option_indices["Mode"]:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(Vector2i(1152, 648))
		1: # Borderless Window cuz why not
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	# --- Apply VSync ---
	match ConfigManager.option_indices["VSync"]:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
