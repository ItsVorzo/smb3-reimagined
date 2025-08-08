extends Node

func _ready() -> void:
	print("Save path: ", get_save_path(0))

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

# Loads game data from disk
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

# Deletes a save file
func delete_save(index: int) -> void:
	var path = get_save_path(index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

# Copies one save slot to another
func copy_save(from_index: int, to_index: int) -> void:
	var from_path = get_save_path(from_index)
	var to_path = get_save_path(to_index)

	if FileAccess.file_exists(from_path):
		var data = load_game(from_index)
		save_game(to_index, data)
