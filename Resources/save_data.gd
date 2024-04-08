class_name SaveData extends JSONLoader

# temp - this needs to be removed from template because it's game, specific (just testing this)
## This class should be customized to include dava validation and helper functions that are specific to 
## the data you want save/access/validate - leaving the JSONLoader class generic and responsible for
## simply reading and writing whatever data is manipulated here

func read_level_progress(level_id: String) -> int:
	# todo - throw error if id or file doesn't exist - possibly handle at JSONLoader?
	return data.level_progress[level_id]
	
func update_level_progress(level_id: String, value, save_now: bool = true) -> void:
	# todo - game-specific data validation before saving
	# todo - throw error if id or file doesn't exist - possibly handle at JSONLoader?
	data.level_progress[level_id] = value
	if save_now:
		write_save(data)
