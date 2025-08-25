extends Node

# A manager for managing multiple player input devices

const max_players = 4

# This is the dictionary used to check which input device is each player id using
var player_data: Dictionary = { 0: { "device": -1 } }

# === Add input devices ===
# Could use these in the character select
# Next input device to add
func next_player() -> int:
	for i in max_players:
		if !player_data.has(i): return i
	return -1
# Add input device to player data
func join(device):
	player_data[next_player()] = {
		"device": device
	}
# Press A to add an input device
func handle_join_input():
	for device in get_unjoined_devices():
		if MultiplayerInput.is_action_just_pressed(device, "A"):
			join(device)
# Disconnect
func leave(player):
	player_data.erase(player)

func leave_device(device: int):
	for player_id in player_data.keys():
		if player_data[player_id].device == device:
			player_data.erase(player_id)
			break

# === Get input device info ===
func get_player_data(player: int, key: StringName):
	if player_data.has(player) and player_data[player].has(key):
		return player_data[player][key]
	return null

func get_player_device(player: int):
	return get_player_data(player, "device")

func is_device_joined(device: int) -> bool:
	for player_id in player_data:
		var d = get_player_device(player_id)
		if device == d: return true
	return false

func get_unjoined_devices():
	var devices = Input.get_connected_joypads()
	# also consider keyboard player
	devices.append(-1)
	
	# filter out devices that are joined:
	return devices.filter(func(device): return !is_device_joined(device))
