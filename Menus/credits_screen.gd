class_name CreditsScreen extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			_on_quit_button_up()

func _on_quit_button_up() -> void:
	SceneManager.swap_scenes(SceneRegistry.main_scenes["StartScreen"],get_tree().root,self,"wipe_to_right")	
