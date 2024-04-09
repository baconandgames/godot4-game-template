class_name JSONLoader extends Node
# https://docs.godotengine.org/en/stable/classes/class_json.html

# todo - support for multiple save files w/ naming, deleting, etc, this one is low on my priority list
# because most of the games I make aren't expected to be played and shared among multiple people on the 
# same computer at the same time

const save_path: String = "user://user_save.json"
const default_save_file: String = "res://Resources/default_save_file.json"
var data = {}

func write_save(data_to_save):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data_to_save))
	file.close()
	file = null
	
func read_save():
	var file = FileAccess.open(save_path, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	data = save_data
	return data
	
func load_or_create():
	if FileAccess.file_exists(save_path):
		return read_save()
	else:
		var file = FileAccess.open(default_save_file, FileAccess.READ)
		var default_data = JSON.parse_string(file.get_as_text())
		data = default_data
		write_save(default_data)
		return data
		
func clear_save():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(default_save_file, FileAccess.READ)
		var default_data = JSON.parse_string(file.get_as_text())
		data = default_data
		write_save(default_data)
		
func _ready() -> void:
	load_or_create()
	#print(data.level_progress["level0"])
	#print(data.level_progress["level1"])
	#print(data.level_progress["level2"])
	#print(data.level_progress["level3"])
	#data.level_progress["level0"] = 1
	#write_save(data)
	
#class_name JSONLoader extends Node2D
#
#@export var json_file:String
#
#func get_json():
	#assert(FileAccess.file_exists(json_file),"File '%s' does not exist" % [json_file])
	#
	#var file := FileAccess.open(json_file, FileAccess.READ)
	#var content:String = file.get_as_text()
	#var data = JSON.parse_string(content)
	#
##	print(data.lang["en-US"].convo01[0].text)
	#return data
