extends Node

func _ready():
	DiscordRPC.app_id = 1402314210444185790
	DiscordRPC.details = "Playing SMB3R"
	DiscordRPC.state = "In Menus"
	DiscordRPC.large_image = "smb3rlogo"
	DiscordRPC.large_image_text = ""
	DiscordRPC.small_image = "smb3rlogo"
	DiscordRPC.small_image_text = ""

	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh() # Always refresh after changing the values!
