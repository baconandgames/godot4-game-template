class_name SettingsMenu extends CanvasLayer

# opening this menu pauses the game, so you don't have to worry about blocking input
# from anything underneath it

# todo - implement fullscreen / window size dropdown Ex:
#	640×360
#	960×540
#	1920×1080
#	1280×720 with a scaling factor of 2.


signal language_changed(language: String)

@onready var music_slider:HSlider = %MusicSlider as HSlider
@onready var sfx_slider:HSlider = %SFXSlider as HSlider
@onready var language_dropdown:OptionButton = %LanguageDropdown as OptionButton
@onready var close_button:Button = %CloseButton as Button
@onready var save_button:Button = %SaveButton as Button
@onready var quit_button:Button = %QuitButton as Button
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs

func _ready():
	# load (or create) file with these saved preferences
	user_prefs = UserPrefs.load_or_create()
	
	# note - if you want the option to save your game from this menu, replace the hardcoded
	# false with logic that assures the game is in a savable state
	save_button.visible = false
	
	# note - change this to true or replace with logic that assure the player is safe to 
	# quit the game from this menu
	quit_button.visible = false
	
	# set saved values (will be default values if first load)
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	if language_dropdown:
		language_dropdown.selected = user_prefs.language

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		close_settings()

func close_settings():
	queue_free()

func _on_close_button_pressed():
	close_settings()
	
func _on_save_button_pressed():
	print("save button pressed")
	# note - this is where I would/will put the ability for players to manually save data
	# Ex: something like the below
	# Globals.user_save.save_all_game_data()

func _on_quit_button_pressed():
	# https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html
	# todo - are you sure prompt
	# todo - save before quitting if in-game
	get_tree().quit()

func _on_music_slider_value_changed(_value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(_value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, _value < .05)
	user_prefs.music_volume = _value

func _on_sfx_slider_value_changed(_value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(_value))
	AudioServer.set_bus_mute(SFX_BUS_ID, _value < .05)
	user_prefs.sfx_volume = _value

func _on_language_dropdown_item_selected(_index):
	# todo - set selected language
	user_prefs.language = _index
	# todo - needs to be wired to a more central place for handling loc (planned for future version)
	language_changed.emit(_index)

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			get_tree().paused = true
		NOTIFICATION_EXIT_TREE:
			user_prefs.save()
			get_tree().paused = false
