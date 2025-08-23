extends Node2D

@onready var music = $TitleMusic
@onready var select = $Select
@onready var movesfx = $Move
@onready var opt1 = $StoryMode
@onready var opt2 = $Options
@onready var leftsqr = $LeftSquare
@onready var rightsqr = $RightSquare

var resume_instance: Node = null
var options_instance: Node = null
var savequit_instance: Node = null

var OptionsScene = preload("res://Scenes/UI/Options.tscn")

func open_options() -> void:
	select.play()
	if options_instance == null or not is_instance_valid(options_instance):
		options_instance = OptionsScene.instantiate()
		add_child(options_instance)
	else:
		print("poopyhead")
