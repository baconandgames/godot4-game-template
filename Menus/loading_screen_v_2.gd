extends Control

## I found the transition between scenes Zelda-like quite interesting, 
## as well as the animated transition. 
## But they involve a lot of auxiliary functions, 
## as a result of which they can be difficult to integrate into various projects
## This loading screen should resemble the loading screens in games 
## such as Elden ring, Skyrim, etc.
## There is a loading bar here, during which you can add Game tips 
## and some images from a limited set.
## The preferred use of this loading screen is for scenes that take a long time to load.
## For example, 3D scenes or scenes containing cutscenes and video clips
## An example of using this boot screen
## [code]
## func _on_start_button_up() -> void:
## 	SceneManager._change_scene(SceneRegistry.levels["game_start"])
## [/code]

@onready var progress_number = $MarginContainer/VBoxContainer/HBoxContainer/ProgressNumber
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var _game_tips = $MarginContainer/GameTips
@onready var _texture_rect = $TextureRect

func _ready():
	## Loading the next scene in the background
	if SceneManager._next_scene == "":
		SceneManager._on_content_invalid(SceneManager._next_scene)
		return
	else:
		ResourceLoader.load_threaded_request(SceneManager._next_scene)


func _process(_delta: float) -> void:
	if SceneManager._next_scene == "":
		return
	else:
		var progress = []
		ResourceLoader.load_threaded_get_status(SceneManager._next_scene, progress)
		progress_bar.value = progress[0]*100
		progress_number.text = str(floor(progress[0]*100))+"%"
		
		if progress[0] == 1:
			var packed_scene = ResourceLoader.load_threaded_get(SceneManager._next_scene)
			get_tree().change_scene_to_packed(packed_scene)
