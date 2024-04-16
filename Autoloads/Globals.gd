extends Node

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs
var game_info: GameInfo
var save:SaveData
#var user_save:UserSave

# temp - I'm not wild about preloads, but this menu is fairly light (to revise in a future version)
var settings_menu_scene:PackedScene = preload("res://Menus/settings_menu.tscn")
var settings_menu = null
var display_manager: DisplayManager
 
# available window resolutions
# perhaps this should be an export on a node for easier management
var window_resolutions: Array[Vector2i] = [
	Vector2i(960,540),
	Vector2i(1280,720),
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(2560,1440),
]

func _ready():
	# setup so that we can intercept quit
	get_tree().set_auto_accept_quit(false)
	
	user_prefs = UserPrefs.load_or_create()
	game_info = GameInfo.load_or_create()
	
	display_manager = DisplayManager.new()
	
	# SaveData extends JSONLoader to add methods to read and write data specifically for this game
	# customize SaveData to fit your game. What's in this repo is just a very basic example.
	save = SaveData.new()
	save.load_or_create()
	
	# todo - will implement Resource saver option in future versions
	#user_save = UserSave.load_or_create() as UserSave
	#user_save.save()
	
	# temp - Will probably relocate to an audio-specfiic class in future versions
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(user_prefs.sfx_volume))
	AudioServer.set_bus_mute(SFX_BUS_ID, user_prefs.sfx_volume < .05)
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(user_prefs.music_volume))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, user_prefs.music_volume < .05)

enum GLOBAL_STATE {
	MAIN_MENU,
	GAMEPLAY,
	CONVERSATION,
	PAUSED
}

const LANGUAGES:Dictionary = {
	0:"en-US",
	1:"es-LAT"
}

func get_selected_language() -> String:
	var s:String = LANGUAGES[user_prefs.language]
	if s:
		return s
	return LANGUAGES[0]

# temp - maybe the settings menu doesn't need to live in a global spot? (will decide in future version)
func open_settings_menu():
	if not settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		get_tree().root.add_child(settings_menu)
	else:
		push_warning('settings menu already exists in this scene')

func quit():
	# todo add confirmation dialog before quitting
	display_manager.save_window()
	get_tree().quit() # default behavior

func _notification(what):
	# intercept window manager quit
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()
