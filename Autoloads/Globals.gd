extends Node

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs
var save:SaveData
#var user_save:UserSave

# temp - I'm not wild about preloads, but this menu is fairly light (to revise in a future version)
var settings_menu_scene:PackedScene = preload("res://Menus/settings_menu.tscn")
var settings_menu = null
 
func _ready():
	user_prefs = UserPrefs.load_or_create()
	
	# temp - need to extend JSONLoader to make a save data wrapper
	save = SaveData.new()
	save.load_or_create()
	#print(save.read_level_progress("level0"))
	#save.update_level_progress("level0", 5)
	
	# todo - need to implement Resource saver option
	#user_save = UserSave.load_or_create() as UserSave
	#user_save.save()
	
	# temp - I'd rather have a more central place for this since this is duplicated code, will do for now
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
