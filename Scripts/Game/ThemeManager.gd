extends Node2D

signal theme_changed(new_theme: String)

@export_enum("Overworld", "Underground", "Desert", "Snow", "Athletic", "Castle")
var theme: String = "Overworld":
	set(value):
		if theme != value:
			theme = value
			emit_signal("theme_changed", value)

func _ready():
	emit_signal("theme_changed", theme)
