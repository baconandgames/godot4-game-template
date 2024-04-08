class_name UserPrefs extends Resource

@export_range(0,1,.05) var music_volume: float = 1.0
@export_range(0,1,.05) var sfx_volume: float = 1.0
@export var use_smooth_movement:bool = true
@export var language:int = 0

const USER_PREFS_PATH:String = "user://user_prefs.tres"

func save() -> void:
	ResourceSaver.save(self, USER_PREFS_PATH)
	
static func load_or_create() -> UserPrefs:
	var res:UserPrefs
	if FileAccess.file_exists(USER_PREFS_PATH):
		res = load(USER_PREFS_PATH) as UserPrefs
	else:
		res = UserPrefs.new()
	return res
