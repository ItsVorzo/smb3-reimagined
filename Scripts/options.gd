extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var back_sound = $BackSound
@onready var switch_tab_sound = $SwitchTabs
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
	# Connect tab buttons
	for name in tabs.keys():
		tabs[name].connect("pressed", Callable(self, "_on_tab_selected").bind(name))

	# Connect option value labels with mouse click detection
	_connect_label_click($Options/Display/ModeValue, "Mode")
	_connect_label_click($Options/Display/VSyncValue, "VSync")
	_connect_label_click($Options/Display/SizeValue, "Size")
	_connect_label_click($Options/Display/DropShadowValue, "DropShadows")

	# Set initial label texts
	for option_name in option_values.keys():
		var initial_value = option_values[option_name][option_indices[option_name]]
		match option_name:
			"Mode":
				$Options/Display/ModeValue.text = initial_value
			"VSync":
				$Options/Display/VSyncValue.text = initial_value
			"Size":
				$Options/Display/SizeValue.text = initial_value
			"DropShadows":
				$Options/Display/DropShadowValue.text = initial_value

	_on_tab_selected("Display")


func _connect_label_click(label_node: Node, option_name: String):
	label_node.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_option_clicked(option_name))

func _on_tab_selected(tab_name: String):
	switch_tab_sound.play()
	# Hide all panels
	for panel in panels.values():
		panel.visible = false

	# Show the selected one
	panels[tab_name].visible = true
	print("Switched to tab:", tab_name)

func _on_option_clicked(option_name: String):
	var values = option_values[option_name]
	option_indices[option_name] = (option_indices[option_name] + 1) % values.size()
	var new_value = values[option_indices[option_name]]

	# Update the correct button's text
	match option_name:
		"Mode":
			$Options/Display/ModeValue.text = new_value
		"VSync":
			$Options/Display/VSyncValue.text = new_value
		"Size":
			$Options/Display/SizeValue.text = new_value
		"DropShadows":
			$Options/Display/DropShadowValue.text = new_value

	print(option_name, "changed to", new_value)
	
func _on_back_pressed() -> void:
	back_sound.play()
	animation_player.play("close")
	await get_tree().create_timer(0.2).timeout
	queue_free()
