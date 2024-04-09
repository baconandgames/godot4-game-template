class_name SaveData extends JSONLoader

# Example accepted data values for this game's save implementation
enum LEVEL_STATUS{
	LOCKED,
	UNLOCKED,
	COMPLETED
}

# This class should be customized to include dava validation and helper functions that are specific to 
# the data you want save/access/validate - leaving the JSONLoader class generic and responsible for
# simply reading and writing whatever data is manipulated here. Everything here is intended to be
# deleted and replaced by logic that suits your game's loading/saving needs

# access level progress. Will return 0 if locked, 1 if unlocked, 2 if completed
func read_level_progress(level_id: String) -> int:
	# throw error if id or file doesn't exist
	assert(!SceneRegistry.levels.has(level_id), "Level with id %s does not exist." % level_id)
	return data.level_progress[level_id]
	
# write new completion data for a given level
func update_level_progress(level_id: String, value: int, save_now: bool = true) -> void:
	# throw error if level doesn't exist
	assert(!SceneRegistry.levels.has(level_id), "Level with id %s does not exist." % level_id)
	# note Example game-speciic validation before saving. Make sure the value we're saving
	# is one of the values we recognize. If not, you can throw an error or default to another
	# value
	if !LEVEL_STATUS.has(value):
		push_error("%s is an unrecognized level progress value. Save aborted." % value)
		return
	
	# after validation, store the new value
	data.level_progress[level_id] = value
	# if save_name is true, write this value immediately to our JSON save file. For tiny updates like this
	# I typically write after every change. If you're writing tons of data, you may choose to update data
	# locally and the save in batches at your discretion
	if save_now: write_save(data)
