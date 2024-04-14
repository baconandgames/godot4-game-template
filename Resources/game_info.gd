class_name GameInfo extends Resource

# could save stats, telemetry, etc

@export var last_window_position: Vector2i

const GAME_INFO_PATH:String = "user://game_info.tres"

func save() -> void:
	ResourceSaver.save(self, GAME_INFO_PATH)
	
static func load_or_create() -> GameInfo:
	var res:GameInfo
	if FileAccess.file_exists(GAME_INFO_PATH):
		res = load(GAME_INFO_PATH) as GameInfo
	else:
		res = GameInfo.new()
	return res
