extends Node

const CONFIG_PATH: String = "user://options_config.json"

var option_values: Dictionary = {
	"Mode": ["windowed", "borderless", "fullscreen"],
	"VSync": ["off", "on"],
	"Size": ["4:3", "extended"],
	"DropShadows": ["off", "on"],
	"CameraMode": ["off", "fixed", "smooth"]
}

var option_indices: Dictionary = {
	"Mode": 0,
	"VSync": 0,
	"Size": 0,
	"DropShadows": 0,
	"CameraMode": 0
}

func _ready() -> void:
	_load_config()
	_apply_options()

func set_option(option_name: String, index: int) -> void:
	if option_name in option_indices:
		option_indices[option_name] = clamp(
			index,
			0,
			option_values[option_name].size() - 1
		)
		_save_config()
		_apply_options()

func _save_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(option_indices))
		file.close()
		print("Config saved:", option_indices)

func _load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var data: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			for option_name in option_indices.keys():
				if option_name in data and (typeof(data[option_name]) in [TYPE_INT, TYPE_FLOAT]):
					option_indices[option_name] = clamp(
						int(data[option_name]),
						0,
						option_values[option_name].size() - 1
					)
	print("Options loaded:", option_indices)

func _apply_options() -> void:
	# --- Apply Mode ---
	match option_indices["Mode"]:
		0: # windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(Vector2i(1152, 648))
		1: # borderless windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: # fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	match option_indices["Size"]:
		0:
			get_window().content_scale_size.x = 256
		1:
			get_window().content_scale_size.x = 426

	# --- Apply VSync ---
	match option_indices["VSync"]:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)

	print(get_viewport().get_visible_rect().size.x)
