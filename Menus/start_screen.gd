class_name StartScreen extends Control
@onready var start = $VBoxContainer/HBoxContainer/GridContainer/Start
@onready var quit = $VBoxContainer/HBoxContainer/GridContainer/Quit
@onready var no = $ConfirmQuit/VBox/NoButton

const template_version: String = "0.1"

# These 4 lines are not covered in the initial video. They've been added here just to make it easier for you
# to differentiate versions. I had not intended to provide updates so this feature was skipped in original code.
@onready var version_num: Label = %VersionNum
func _ready() -> void:
	version_num.text = "v%s" % template_version
	start.grab_focus()

func _on_start_button_up() -> void:
	SceneManager.swap_scenes(SceneRegistry.levels["game_start"],get_tree().root,self,"wipe_to_right")	

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	$ConfirmQuit.visible = true
	no.grab_focus()

func _on_no_button_pressed() -> void:
	quit.grab_focus()
	$ConfirmQuit.visible = false

func _on_yes_button_pressed() -> void:
	get_tree().quit()
