extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var back_sound = $BackSound
@onready var switch_tab_sound = $SwitchTabs
@onready var change_option_sound = $ChangeOption

@onready var tabs = {
	"Display": $Tabs/Display,
	"Audio": $Tabs/Audio,
	"Gameplay": $Tabs/Gameplay,
	"Moveset": $Tabs/Moveset,
	"Sprites": $Tabs/Sprites
}

@onready var panels = {
	"Display": $Options/Display,
	"Audio": $Options/Audio,
	"Gameplay": $Options/Gameplay,
	"Moveset": $Options/Moveset,
	"Sprites": $Options/Sprites
}

# Test values for cycling
var option_values = {
	"Mode": ["windowed", "borderless full", "fullscreen"],
	"VSync": ["off", "on"],
	"Size": ["4:3", "extended"],
	"DropShadows": ["off", "on"]
}

# Tracks current index for each option
var option_indices = {
	"Mode": 0,
	"VSync": 0,
	"Size": 0,
	"DropShadows": 0
}

func _ready():
	# --- Connect tabs ---
	for name in tabs.keys():
		tabs[name].connect("pressed", Callable(self, "_on_tab_selected").bind(name))

	# --- Connect option value buttons ---
	_connect_value_button($Options/Display/ModeValueButton, "Mode")
	_connect_value_button($Options/Display/VSyncValueButton, "VSync")
	_connect_value_button($Options/Display/SizeValueButton, "Size")
	_connect_value_button($Options/Display/DropShadowValueButton, "DropShadows")

	# --- Set initial label texts ---
	for option_name in option_values.keys():
		_set_option_text(option_name, option_values[option_name][option_indices[option_name]])

	# Show default tab
	_on_tab_selected("Display")


func _connect_value_button(button: Button, option_name: String):
	button.pressed.connect(func():
		_on_option_clicked(option_name))


func _on_tab_selected(tab_name: String):
	switch_tab_sound.play()
	# Hide all panels
	for panel in panels.values():
		panel.visible = false
	# Show selected one
	panels[tab_name].visible = true
	print("Switched to tab:", tab_name)


func _on_option_clicked(option_name: String):
	change_option_sound.play()
	var values = option_values[option_name]
	option_indices[option_name] = (option_indices[option_name] + 1) % values.size()
	var new_value = values[option_indices[option_name]]
	_set_option_text(option_name, new_value)
	print(option_name, "changed to ", new_value)


func _set_option_text(option_name: String, text: String):
	match option_name:
		"Mode":
			$Options/Display/ModeValueButton/ModeValue.text = text
		"VSync":
			$Options/Display/VSyncValueButton/VSyncValue.text = text
		"Size":
			$Options/Display/SizeValueButton/SizeValue.text = text
		"DropShadows":
			$Options/Display/DropShadowValueButton/DropShadowValue.text = text


func _on_back_pressed() -> void:
	back_sound.play()
	animation_player.play("close")
	await get_tree().create_timer(0.2).timeout
	queue_free()
