extends Node

class_name Settings

var settings_save_path = "user://settings.res"
#
#func _ready():
#	if ResourceLoader.exists(settings_save_path):
#		load_settings()
#
#func save_settings():
#	ResourceSaver.save(Settings, settings_save_path)
#
#func load_settings():
#	ResourceLoader.load(settings_save_path)
	
@export var type_sound : int = 1
@export var theme : Resource
@export var font_size : int = 0

func get_formal_filepath(file_name):
	var formatted_file_path = "user://" + file_name + ".json"
	return formatted_file_path
	
func if_file_exists(file_path):
	file_path = get_formal_filepath(file_path)
	if FileAccess.file_exists(file_path):
		return true
	else:
		return false
			
