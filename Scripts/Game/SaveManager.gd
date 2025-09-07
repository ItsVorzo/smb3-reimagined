extends Node

var runtime_data: Dictionary = {}
var temp_level_data: Dictionary = {}  # <-- NEW: temp save for current level
var hud: Node = null  # Stores reference to HUD for fast access

func _ready() -> void:
	print("Save path: ", get_save_path(0))

# --- File Helpers ---
func get_custom_save_dir() -> String:
	var base_path := OS.get_user_data_dir()
	var save_dir := base_path.path_join("SMB3R/saves")
	DirAccess.make_dir_recursive_absolute(save_dir)
	return save_dir

func get_save_path(index: int) -> String:
	return get_custom_save_dir().path_join("save_%d.json" % index)

func save_game(index: int, data: Dictionary) -> void:
	var file = FileAccess.open(get_save_path(index), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
	else:
		push_error("Failed to open save file for writing: %s" % get_save_path(index))

func load_game(index: int) -> Dictionary:
	var path = get_save_path(index)
	if not FileAccess.file_exists(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var result = JSON.parse_string(content)
		if result is Dictionary:
			return result

	return {}

func delete_save(index: int) -> void:
	var path = get_save_path(index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func copy_save(from_index: int, to_index: int) -> void:
	var data = load_game(from_index)
	save_game(to_index, data)

# --- RUNTIME & TEMP SAVE HANDLING ---
func start_runtime_from_save(save_index: int) -> void:
	var permanent = load_game(save_index)
	if permanent.is_empty():
		permanent = {
			"character_index": 0,
			"world_number": 1,
			"score": 0,
			"coins": 0,
			"lives": 3,
			"time": 400,
			"powerup_state": "Small"
		}
	runtime_data = permanent.duplicate(true)
	
	# Initialize temp level save
	temp_level_data = {
		"time": runtime_data.get("time", 400),
		"timer_paused": false
	}

# Accessors for temp level data
func get_temp(key: String, default=null):
	return temp_level_data.get(key, default)

func set_temp(key: String, value):
	temp_level_data[key] = value

# Save runtime_data to permanent save (never includes temp_level_data)
func commit_runtime_to_save(save_index: int) -> void:
	var save_copy = runtime_data.duplicate(true)
	# Remove temp-only keys if they exist (just in case)
	save_copy.erase("time")
	save_copy.erase("timer_paused")
	save_game(save_index, save_copy)

func clear_runtime() -> void:
	runtime_data.clear()
	temp_level_data.clear()

func add_life(amount: int) -> void:
	var lives = runtime_data.get("lives", 3) + amount
	runtime_data["lives"] = lives
	commit_runtime_to_save(0)

func add_score(amount: int) -> void:
	SaveManager.runtime_data["score"] = SaveManager.runtime_data.get("score", 0) + amount
	if SaveManager.hud and SaveManager.hud.has_method("update_labels"):
		SaveManager.hud.update_labels()
