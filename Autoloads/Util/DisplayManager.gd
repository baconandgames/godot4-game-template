class_name DisplayManager extends Object

# available window resolutions
# perhaps this should be an export on a node for easier management
static var window_resolutions: Array[Vector2i] = [
	Vector2i(960,540),
	Vector2i(1280,720),
	Vector2i(1600,900),
	Vector2i(1920,1080),
	Vector2i(2560,1440),
]

func _init():
	restore_window()

func set_window_mode(_value: int):
	match(_value):
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func set_window_resolution(_resolution: Vector2i):
	DisplayServer.window_set_size(_resolution)

func set_monitor(_monitor: int):
	DisplayServer.window_set_current_screen(_monitor)

func save_window():
	Globals.game_info.last_window_position = DisplayServer.window_get_position()
	Globals.game_info.save()

func restore_window():
	set_window_mode(Globals.user_prefs.window_mode)
	set_window_resolution(Globals.user_prefs.window_resolution)
	set_monitor(Globals.user_prefs.window_monitor)
	# if we don't have a saved window position
	# or our saved position is off screen
	# center our position
	var screen_size := DisplayServer.screen_get_size()
	var window_size := DisplayServer.window_get_size()
	var last_win_pos := Globals.game_info.last_window_position
	if last_win_pos == Vector2i(0, 0) \
	or last_win_pos.x > screen_size.x - 250 \
	or last_win_pos.y > screen_size.y - 250 \
	or last_win_pos.x + window_size.x < 250 \
	or last_win_pos.y + window_size.y < 250:
		Globals.game_info.last_window_position = screen_size / 2 - window_size / 2
	DisplayServer.window_set_position(Globals.game_info.last_window_position)
