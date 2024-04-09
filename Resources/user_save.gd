class_name UserSave extends Resource

## This script is a placeholder for a forthcoming Resource saver. At present
## this template has only implemented saving/loading json files.

const USER_SAVE_PATH:String = "user://user_save.tres"
#const FIRST_LEVEL_ID:String = "level02"
#const NULL_VECTOR:Vector2 = Vector2(-50000,-50000)
#
#@export var player_position:Vector2
#@export var level_objects_reset:Dictionary = {}
#@export var level_objects_save:Dictionary = {}
#@export var last_level_id:String


#func save() -> void:
	##print("save ",player_position)
	#ResourceSaver.save(self, USER_SAVE_PATH)
	#
#static func load_or_create() -> UserSave:
	#var res:UserSave
	#if FileAccess.file_exists(USER_SAVE_PATH):
		#print("file exists, load it")
		#res =  load(USER_SAVE_PATH) as UserSave
	#else:
		#print("file doesn't exist, create one")
		#res = UserSave.new()
		##res.player_position = NULL_VECTOR
	#return res
	#
#func get_room_save(level_id:String) -> RoomSave:
	#var room_save:RoomSave = null
	#if level_objects_save.has(level_id):
		#room_save = level_objects_save[level_id]
	#return room_save
	#
#func init_level_objects(_level:Level):
	#var level_id = _level.level_id
	#if !level_objects_reset.has(level_id):
		#level_objects_reset[level_id] = RoomSave.new()
		#level_objects_save[level_id] = RoomSave.new()
		#var tiles = _level.game_tiles.get_children()
		#for tile in tiles:
			#var save_data_tile:SaveDataTile = SaveDataTile.new(tile.name,tile.position,tile.rotation,tile.removed,tile.no_reset)
			#level_objects_reset[level_id].game_tiles.push_front(save_data_tile)
			#level_objects_save[level_id].game_tiles.push_front(save_data_tile)
		#save()
		#
#func save_level_objects(_level:Level):
	#var level_id = _level.level_id
	#if level_objects_save.has(level_id):
		#level_objects_save[level_id] = RoomSave.new()
		#var tiles = _level.game_tiles.get_children()
		#for tile in tiles:
			#print("saving: ",tile.name)
			#var save_data_tile:SaveDataTile = SaveDataTile.new(tile.name,tile.position,tile.rotation,tile.removed,tile.no_reset)
			#level_objects_save[level_id].game_tiles.push_front(save_data_tile)
	#else:
		#printerr("no save file for level %s exists" % [_level.level_id])
#
##func get_player_starting_position_from_save(_level:Level) -> Vector2:
##	return level_objects_save[_level.level_id].player_position
#
#func save_all_game_data(_level:Level=null):
	#if _level == null:
		#_level = Globals.current_level
	#save_level_objects(_level)
	#save()
