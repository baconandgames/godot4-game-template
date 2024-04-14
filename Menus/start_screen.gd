class_name StartScreen extends Control

const template_version: String = "0.1"

# These 4 lines are not covered in the initial video. They've been added here just to make it easier for you
# to differentiate versions. I had not intended to provide updates so this feature was skipped in original code.
@onready var version_num: Label = %VersionNum
func _ready() -> void:
	version_num.text = "v%s" % template_version
	# we don't have a saved window position
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

func _on_start_button_up() -> void:
	SceneManager.swap_scenes(SceneRegistry.levels["game_start"],get_tree().root,self,"wipe_to_right")	

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	# todo add confirmation dialog before quitting
	Globals.save_game_info()
	get_tree().quit()
