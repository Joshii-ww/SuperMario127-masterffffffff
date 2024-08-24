extends Node

const LEVELS_DIRECTORY = "user://levels/"
const LEVEL_DISK_PATHS_PATH = LEVELS_DIRECTORY + "paths.json"
const TEMPLATE_LEVELS_DIRECTORY = "user://template_levels/"
const TEMPLATE_LEVEL_DISK_PATHS_PATH = TEMPLATE_LEVELS_DIRECTORY + "paths.json"
const COMMUNITY_LEVELS_DIRECTORY = TEMPLATE_LEVELS_DIRECTORY + "best_of_community/"
const COMMUNITY_LEVEL_DISK_PATHS_PATH = COMMUNITY_LEVELS_DIRECTORY + "paths.json"
const ENCRYPTION_PASSWORD = "BadCode"

const NO_LEVEL : int = -1

var levels : Array = [] # array of type LevelInfo
var levels_disk_paths : Array = [] # array of type String
var template_levels : Array = [] # array of type LevelInfo
var template_levels_disk_paths : Array = [] # array of type String
var community_levels : Array = [] # array of type LevelInfo
var community_levels_disk_paths : Array = [] # array of type String
var selected_level : int = NO_LEVEL

# Resource paths to load level codes to create template_levels array from.
var template_level_codes : Array = [ 
	"res://level/template_levels/tutorial_hills.tres",  
	"res://level/template_levels/waterfloat_galaxy.tres",
	"res://level/template_levels/prism_star_galaxy.tres",
	"res://level/template_levels/sunset_grove.tres",
	"res://level/template_levels/wet_freeze_cave.tres",
	"res://level/template_levels/pastel_citadel.tres",
	"res://level/template_levels/gold_rush_gulch.tres",
	"res://level/template_levels/towering_towers.tres",
	"res://level/template_levels/warp_palace.tres",
	"res://level/template_levels/mortal_magma_land.tres",
	"res://level/template_levels/lost_cave.tres",
	"res://level/template_levels/green_demon_cave.tres",
	"res://level/template_levels/torrent_park.tres"
]

var community_level_codes : Array = [
	"res://level/community_levels/ruins_of_the_misty_peaks.tres",
	"res://level/community_levels/yume_mario.tres"
]

# for the levels list and get_current_levels()
var is_template_list : bool = false

# we can just reuse these objects for everything involving files, nothing will happen in parallel atm anyway
var file : File = File.new()
var directory : Directory = Directory.new()

func _ready() -> void:
	load_level_paths_from_disk()
	for level_path in levels_disk_paths:
		load_level_from_disk(level_path)
	prepare_template_levels()
	prepare_community_levels()

func wipe_template_levels():
	var dir = Directory.new()
	dir.open("user://template_levels")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		dir.remove(file_name)
		file_name = dir.get_next()

func load_levels_from_resources(list: Array):
	for i in range(list.size()):
		var path : String = list[i]

		var f = File.new()
		var err = f.open(path, File.READ)
		if err == OK:
			list[i] = f.get_as_text()
			
		f.close()

func prepare_template_levels() -> void:
	load_levels_from_resources(template_level_codes)

	for level_path in template_levels_disk_paths:
		load_template_level_from_disk(level_path)

	for level_code in template_level_codes:
		var level_exists := false
		for level in template_levels:
			if level.level_code == level_code:
				level_exists = true
				break

		if !level_exists:
			var level_info := LevelInfo.new(level_code)
			add_template_level(level_info)

func prepare_community_levels() -> void:
	load_levels_from_resources(community_level_codes)

	for level_path in community_levels_disk_paths:
		load_community_level_from_disk(level_path)

	for level_code in community_level_codes:
		var level_exists := false
		for level in community_levels:
			if level.level_code == level_code:
				level_exists = true
				break

		if !level_exists:
			var level_info := LevelInfo.new(level_code)
			add_community_level(level_info)


func add_template_level(level_info : LevelInfo):
	# Failsafe, prevents illegal levels from being added
	if !template_level_codes.has(level_info.level_code):
		return

	# generate a (hopefully) unique name for each level
	var level_disk_path = generate_template_level_disk_path(level_info)

	var error_code = save_template_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		template_levels.append(level_info)
		template_levels_disk_paths.append(level_disk_path)
		save_level_paths_to_disk()

func add_community_level(level_info : LevelInfo):
	# Failsafe, prevents illegal levels from being added
	if !community_level_codes.has(level_info.level_code):
		return

	# generate a (hopefully) unique name for each level
	var level_disk_path = generate_community_level_disk_path(level_info)

	var error_code = save_community_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		community_levels.append(level_info)
		community_levels_disk_paths.append(level_disk_path)
		save_level_paths_to_disk()

func get_current_levels() -> Array:
	return template_levels if is_template_list else levels

# ////////////////
# Level disk paths
# ////////////////

func generate_level_disk_path(level_info : LevelInfo) -> String:
	return LEVELS_DIRECTORY + "%s_%s.level" % [hash(level_info), hash(OS.get_datetime())]

func generate_template_level_disk_path(level_info : LevelInfo) -> String:
	return TEMPLATE_LEVELS_DIRECTORY + "%s_%s.level" % [hash(level_info), hash(OS.get_datetime())]

func generate_community_level_disk_path(level_info : LevelInfo) -> String:
	return COMMUNITY_LEVELS_DIRECTORY + "%s_%s.level" % [hash(level_info), hash(OS.get_datetime())]


func save_level_paths_to_disk_of(levels_directory: String, level_paths_path: String, levels_disk_paths: Array) -> void:
	var levels_disk_paths_json = to_json(levels_disk_paths)

	if !directory.dir_exists(levels_directory):
		var _error_code = directory.make_dir_recursive(levels_directory)

	var error_code = file.open(level_paths_path, File.WRITE)
	if error_code == OK:
		file.store_string(levels_disk_paths_json)
		file.close()

func save_level_paths_to_disk() -> void:
	save_level_paths_to_disk_of(LEVELS_DIRECTORY, LEVEL_DISK_PATHS_PATH, levels_disk_paths) # User levels
	save_level_paths_to_disk_of(TEMPLATE_LEVELS_DIRECTORY, TEMPLATE_LEVEL_DISK_PATHS_PATH, template_levels_disk_paths) # Template levels
	save_level_paths_to_disk_of(COMMUNITY_LEVELS_DIRECTORY, COMMUNITY_LEVEL_DISK_PATHS_PATH, community_levels_disk_paths) # Community level pack

func load_level_paths_from_disk_for(level_disk_paths_path: String, array_to: Array) -> void:
	var error_code = file.open(level_disk_paths_path, File.READ)
	if error_code == OK:
		var levels_disk_paths_json = file.get_line()

		# Had to do this because "array_to =" overwrites the whole variable rather than the array it is pointing to
		array_to.clear()
		var parsed_json : Array = parse_json(levels_disk_paths_json)
		for level_path in parsed_json:
			array_to.append(level_path)

		file.close()

func load_level_paths_from_disk() -> void:
	load_level_paths_from_disk_for(LEVEL_DISK_PATHS_PATH, levels_disk_paths)
	load_level_paths_from_disk_for(TEMPLATE_LEVEL_DISK_PATHS_PATH, template_levels_disk_paths)
	load_level_paths_from_disk_for(COMMUNITY_LEVEL_DISK_PATHS_PATH, community_levels_disk_paths)



# /////////////////////////
# Saving and loading levels
# /////////////////////////

func load_level_from_disk(level_path : String) -> void:
	var error_code = file.open_encrypted_with_pass(level_path, File.READ, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary_json = file.get_line()
		var level_save_dictionary = parse_json(level_save_dictionary_json)

		var level_info = LevelInfo.new()
		level_info.load_from_dictionary(level_save_dictionary)

		levels.append(level_info)

		file.close()

# returns an error code
func save_level_to_disk(level_info : LevelInfo, level_path : String) -> int:
	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open_encrypted_with_pass(level_path, File.WRITE, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary = level_info.get_saveable_dictionary()
		var level_save_dictionary_json = to_json(level_save_dictionary)
		file.store_string(level_save_dictionary_json)
		file.close()
	return OK
	
func manual_autosave_level_to_disk(level_code, level_path : String) -> int:
	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open(level_path, File.WRITE)
	if error_code == OK:
		file.store_string(level_code)
		file.close()
	return OK
	
func autosave_level_to_disk(level_info : LevelInfo, level_path : String) -> int:
	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open(level_path, File.WRITE)
	if error_code == OK:
		var time = Time.get_unix_time_from_system()
		var level_save_dictionary = level_info.get_saveable_dictionary()
		var level_save_dictionary_json = to_json(level_save_dictionary)
		file.store_string(str(time) + "\n")
		file.store_string(level_save_dictionary_json)
		file.close()
	return OK

func save_level_by_index(level_index : int) -> int:
	var level_info = template_levels[level_index] if is_template_list else levels[level_index]
	var level_path = template_levels_disk_paths[level_index] if is_template_list else levels_disk_paths[level_index]
	if is_template_list:
		return save_template_level_to_disk(level_info, level_path)
	# You can pretend there's an else here
	return save_level_to_disk(level_info, level_path)

func delete_level_from_disk(level_path : String) -> void:
	var _error_code = directory.remove(level_path)


# /////////////////////////////////////
# Special functions for template levels
# (We have to be careful so that normal
# levels have no chance of slipping in)
# /////////////////////////////////////

func load_template_level_from_disk(level_path : String) -> void:
	var error_code = file.open_encrypted_with_pass(level_path, File.READ, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary_json = file.get_line()
		var level_save_dictionary = parse_json(level_save_dictionary_json)

		var level_info = LevelInfo.new()
		level_info.load_from_dictionary(level_save_dictionary)

		# Failsafe, prevents illegal levels from being loaded
		if template_level_codes.has(level_info.level_code):
			template_levels.append(level_info)

		file.close()

func load_community_level_from_disk(level_path : String) -> void:
	var error_code = file.open_encrypted_with_pass(level_path, File.READ, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary_json = file.get_line()
		var level_save_dictionary = parse_json(level_save_dictionary_json)

		var level_info = LevelInfo.new()
		level_info.load_from_dictionary(level_save_dictionary)

		# Failsafe, prevents illegal levels from being loaded
		if community_level_codes.has(level_info.level_code):
			community_levels.append(level_info)

		file.close()

# returns an error code
func save_template_level_to_disk(level_info : LevelInfo, level_path : String) -> int:
	if !directory.dir_exists(TEMPLATE_LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(TEMPLATE_LEVELS_DIRECTORY)

	# Failsafe, prevents illegal levels from being saved
	if template_level_codes.has(level_info.level_code):
		var error_code = file.open_encrypted_with_pass(level_path, File.WRITE, ENCRYPTION_PASSWORD)
		if error_code == OK:
			var level_save_dictionary = level_info.get_saveable_dictionary()
			var level_save_dictionary_json = to_json(level_save_dictionary)
			file.store_string(level_save_dictionary_json)
			file.close()
	return OK

# returns an error code
func save_community_level_to_disk(level_info : LevelInfo, level_path : String) -> int:
	if !directory.dir_exists(COMMUNITY_LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(COMMUNITY_LEVELS_DIRECTORY)

	# Failsafe, prevents illegal levels from being saved
	if community_level_codes.has(level_info.level_code):
		var error_code = file.open_encrypted_with_pass(level_path, File.WRITE, ENCRYPTION_PASSWORD)
		if error_code == OK:
			var level_save_dictionary = level_info.get_saveable_dictionary()
			var level_save_dictionary_json = to_json(level_save_dictionary)
			file.store_string(level_save_dictionary_json)
			file.close()
	return OK
