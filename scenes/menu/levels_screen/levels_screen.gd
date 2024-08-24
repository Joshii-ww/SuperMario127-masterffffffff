extends Screen


signal open_delete_confirmation_popup


onready var level_list:ItemList = $MarginContainer / HBoxContainer / VBoxContainer / LevelListPanel / VBoxContainer / LevelList


onready var button_back:Button = $MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / ButtonBack
onready var button_add:Button = $MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / ButtonAdd
onready var button_copy_code:Button = $MarginContainer / HBoxContainer / VBoxContainer / HBoxContainer / ButtonCopyCode

onready var button_community_levels = $MarginContainer / HBoxContainer / VBoxContainer / LevelListPanel / VBoxContainer / CommunityLevelsButton
onready var button_sample_levels = $MarginContainer / HBoxContainer / VBoxContainer / LevelListPanel / VBoxContainer / SampleLevelsButton

onready var button_new_level:Button = $MarginContainer / HBoxContainer / VBoxContainer / LevelCodePanel / PanelContainer / VBoxContainer / HBoxContainer / ButtonNewLevel
onready var button_code_import:Button = $MarginContainer / HBoxContainer / VBoxContainer / LevelCodePanel / PanelContainer / VBoxContainer / HBoxContainer / ButtonCodeImport
onready var button_code_cancel:Button = $MarginContainer / HBoxContainer / VBoxContainer / LevelCodePanel / PanelContainer / VBoxContainer / ButtonCodeCancel

onready var button_play:Button = $MarginContainer / HBoxContainer / LevelInfo / ControlButtons / ButtonPlay
onready var button_edit:Button = $MarginContainer / HBoxContainer / LevelInfo / ControlButtons / ButtonEdit
onready var button_delete:Button = $MarginContainer / HBoxContainer / LevelInfo / ControlButtons / ButtonDelete
onready var button_reset:Button = $MarginContainer / HBoxContainer / LevelInfo / ControlButtons / ButtonReset

onready var button_time_scores:Button = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / ButtonTimeScores
onready var button_close_time_scores:Button = $MarginContainer / HBoxContainer / TimeScorePanel / PanelContainer / VBoxContainer / ButtonCloseTimeScore


onready var template_level_info:PanelContainer = $MarginContainer / HBoxContainer / VBoxContainer / TemplateLevelInfo
onready var level_list_panel:PanelContainer = $MarginContainer / HBoxContainer / VBoxContainer / LevelListPanel
onready var level_code_panel:PanelContainer = $MarginContainer / HBoxContainer / VBoxContainer / LevelCodePanel
onready var single_time_score_panel:PanelContainer = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / SingleTimeScorePanel
onready var level_info_panel:VBoxContainer = $MarginContainer / HBoxContainer / LevelInfo
onready var time_score_panel:PanelContainer = $MarginContainer / HBoxContainer / TimeScorePanel


onready var level_sky_thumbnail:TextureRect = $MarginContainer / HBoxContainer / LevelInfo / LevelThumbnail / PanelContainer / ThumbnailImage
onready var level_foreground_thumbnail:TextureRect = $MarginContainer / HBoxContainer / LevelInfo / LevelThumbnail / PanelContainer / ForegroundThumbnailImage
onready var level_name_label:Label = $MarginContainer / HBoxContainer / LevelInfo / LevelName
onready var shine_progress:Label = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / ShineProgressPanel / HBoxContainer2 / ShineProgressLabel
onready var star_coin_progress:Label = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / StarCoinProgressPanel / HBoxContainer3 / StarCoinProgressLabel
onready var coin_score:Label = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / CoinScorePanel / HBoxContainer2 / Label
onready var single_time_score:Label = $MarginContainer / HBoxContainer / LevelInfo / LevelScore / SingleTimeScorePanel / HBoxContainer3 / Label
onready var time_score_list:ItemList = $MarginContainer / HBoxContainer / TimeScorePanel / PanelContainer / VBoxContainer / TimeScoreList

onready var level_code_entry:TextEdit = $MarginContainer / HBoxContainer / VBoxContainer / LevelCodePanel / PanelContainer / VBoxContainer / LevelCodeEntry

onready var pop_up_container = $PopupContainer
onready var confirm_delete_window = $PopupContainer / ConfirmDelete
const PLAYER_SCENE:PackedScene = preload("res://scenes/player/player.tscn")
const EDITOR_SCENE:PackedScene = preload("res://scenes/editor/editor.tscn")

const TEMPLATE_LEVEL:String = preload("res://assets/level_data/template_level.tres").contents

const NO_LEVEL:int = - 1

const DEFAULT_SKY_THUMBNAIL:StreamTexture = preload("res://scenes/shared/background/backgrounds/day/day.png")
const DEFAULT_FOREGROUND_MODULATE:Color = Color(1, 1, 1)
const DEFAULT_FOREGROUND_THUMBNAIL:StreamTexture = preload("res://scenes/shared/background/foregrounds/hills/preview.png")

var levels = Singleton.SavedLevels.levels

var double_click: = false

var show_sample_levels: = true

var is_dark:bool = false

func toggle_dark_mode():
	if Singleton2.dark_mode:
		$TransitionRect.modulate = Color(0, 0, 0)
		is_dark = true
	else :
		$TransitionRect.modulate = Color(1, 1, 1)
		is_dark = false

func _ready()->void :
	Singleton2.save_ghost = false
	
	toggle_dark_mode()
	Singleton2.connect("dark_mode_toggled", self, "toggle_dark_mode")
	
	var _connect

	_connect = level_list.connect("item_selected", self, "on_level_selected")

	_connect = button_back.connect("pressed", self, "on_button_back_pressed")
	_connect = button_add.connect("pressed", self, "on_button_add_pressed")
	_connect = button_copy_code.connect("pressed", self, "on_button_copy_code_pressed")

	_connect = button_new_level.connect("pressed", self, "on_button_new_level_pressed")
	_connect = button_code_import.connect("pressed", self, "on_button_code_import_pressed")
	_connect = button_code_cancel.connect("pressed", self, "on_button_code_cancel_pressed")
	_connect = level_code_entry.connect("focus_entered", self, "info_clicked")

	_connect = button_community_levels.connect("pressed", self, "on_button_community_levels_pressed")
	_connect = button_sample_levels.connect("pressed", self, "on_button_sample_levels_pressed")
	
	_connect = button_play.connect("pressed", self, "on_button_play_pressed")
	_connect = button_edit.connect("pressed", self, "on_button_edit_pressed")
	_connect = button_delete.connect("pressed", self, "on_button_delete_pressed")
	_connect = button_reset.connect("pressed", self, "on_button_reset_pressed")

	_connect = button_time_scores.connect("pressed", self, "on_button_time_scores_pressed")
	_connect = button_close_time_scores.connect("pressed", self, "on_button_close_time_scores_pressed")
	
	_connect = confirm_delete_window.connect("confirmed", self, "delete_level")
	_connect = connect("open_delete_confirmation_popup", confirm_delete_window, "popup_centered")

	_pre_open_screen()

func _pre_open_screen()->void :
	print(get_parent().get_parent().previous_screen)
	if not "ShineSelectScreen" in str(get_parent().get_parent().previous_screen):
		$TransitionRect.visible = false
	if Singleton.SavedLevels.is_template_list:
		if show_sample_levels:
			button_sample_levels.visible = false
			levels = Singleton.SavedLevels.template_levels
		else :
			button_sample_levels.visible = true
			levels = Singleton.SavedLevels.community_levels
			pass
	else :
		button_sample_levels.visible = false
		levels = Singleton.SavedLevels.levels
	print("Levels: ", levels.size())
	
	for button in [button_add]:
		button.disabled = Singleton.SavedLevels.is_template_list
	template_level_info.visible = Singleton.SavedLevels.is_template_list
	button_copy_code.text = "Copy to Levels" if Singleton.SavedLevels.is_template_list else "Copy Level Code"
	
	
	level_list.clear()
	for level_info in levels:
		level_list.add_item(level_info.level_name)
	
	
	if levels.size() == 0:
		Singleton.SavedLevels.selected_level = NO_LEVEL
		populate_info_panel()
	elif Singleton.SavedLevels.selected_level != NO_LEVEL:
		
		if Singleton.SavedLevels.selected_level < levels.size():
			populate_info_panel(levels[Singleton.SavedLevels.selected_level])
		level_list.select(Singleton.SavedLevels.selected_level)
	else :
		populate_info_panel(levels[0])
		Singleton.SavedLevels.selected_level = 0
		level_list.select(0)

func _input(event:InputEvent)->void :
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			double_click = event.doubleclick
	
	if not can_interact or get_focus_owner() != null:
		return 
	
	if Input.is_action_just_pressed("ui_up"):
		button_play.grab_focus()
	elif Input.is_action_just_pressed("ui_down"):
		level_list.grab_focus()
	elif Input.is_action_just_pressed("ui_left"):
		button_reset.grab_focus()
	elif Input.is_action_just_pressed("ui_right"):
		button_back.grab_focus()
	elif Input.is_action_just_pressed("switch_modes"):
		start_level(false)

func populate_info_panel(level_info:LevelInfo = null)->void :
	if level_info != null:
		level_name_label.text = level_info.level_name

		
		var total_shine_count: = 0
		var collected_shine_count: = 0

		for shine_details in level_info.shine_details:
			total_shine_count += 1
			if level_info.collected_shines[str(shine_details["id"])]:
				collected_shine_count += 1

		shine_progress.text = "%s/%s" % [collected_shine_count, total_shine_count]

		var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
		star_coin_progress.text = "%s/%s" % [collected_star_coin_count, level_info.collected_star_coins.size()]
		
		
		level_sky_thumbnail.texture = level_info.get_level_background_texture()
		level_foreground_thumbnail.modulate = level_info.get_level_background_modulate()
		level_foreground_thumbnail.texture = level_info.get_level_foreground_texture()

		coin_score.text = str(level_info.coin_score)

		
		
		if level_info.shine_details.size() > 1:
			set_time_score_button(true)

			time_score_list.clear()
			
			var time_scores = level_info.time_scores.values()

			var shine_details_sorted = ([] + level_info.shine_details)
			shine_details_sorted.sort_custom(LevelInfo, "shine_sort")
			
			for shine_detail in shine_details_sorted:
				var index = 0
				for shine_detail_2 in level_info.shine_details:
					if shine_detail["id"] == shine_detail_2["id"]:
						break
					index += 1
				
				var time_score = time_scores[shine_detail.id if shine_detail.id < time_scores.size() else (time_scores.size() - 1)]
				if time_score != - 1:
					var time_score_string:String = LevelInfo.generate_time_string(time_score)
					time_score_list.add_item(shine_detail.title + ":")
					time_score_list.add_item(time_score_string)
				else :
					time_score_list.add_item(shine_detail.title + ":")
					time_score_list.add_item(":\n--:--.--")
		else :
			set_time_score_button(false)
			
			if level_info.time_scores.size() > 0 and level_info.time_scores.values()[0] != LevelInfo.EMPTY_TIME_SCORE:
				single_time_score.text = LevelInfo.generate_time_string(level_info.time_scores.values()[0])
			else :
				single_time_score.text = "--:--.--"
		
		set_control_buttons(true)
		
	else :
		level_name_label.text = ""
		shine_progress.text = "0/0"
		star_coin_progress.text = "0/0"

		level_sky_thumbnail.texture = DEFAULT_SKY_THUMBNAIL
		level_foreground_thumbnail.modulate = DEFAULT_FOREGROUND_MODULATE
		level_foreground_thumbnail.texture = DEFAULT_FOREGROUND_THUMBNAIL

		coin_score.text = str(0)

		single_time_score.text = "--:--.--"
		set_time_score_button(false)

		set_control_buttons(false)

func add_level(level_info:LevelInfo):
	if Singleton.SavedLevels.is_template_list:return 
	
	var level_disk_path = Singleton.SavedLevels.generate_level_disk_path(level_info)

	var error_code = Singleton.SavedLevels.save_level_to_disk(level_info, level_disk_path)
	if error_code == OK:
		levels.append(level_info)
		level_list.add_item(level_info.level_name)

		Singleton.SavedLevels.levels_disk_paths.append(level_disk_path)
		Singleton.SavedLevels.save_level_paths_to_disk()

func delete_level(index:int)->void :
	if Singleton.SavedLevels.is_template_list:return 
	var level_disk_path = Singleton.SavedLevels.levels_disk_paths[index]

	levels.remove(index)
	Singleton.SavedLevels.levels_disk_paths.remove(index)
	level_list.remove_item(index)

	Singleton.SavedLevels.save_level_paths_to_disk()
	Singleton.SavedLevels.delete_level_from_disk(level_disk_path)

	
	
	var level_count = levels.size()
	var selected_level = Singleton.SavedLevels.selected_level * int(level_count > 0) + NO_LEVEL * int( not level_count > 0)
	
	selected_level -= 1 * int(selected_level + 1 > level_count)
	level_list.select(selected_level)

	Singleton.SavedLevels.selected_level = selected_level

	
	populate_info_panel(levels[selected_level] if selected_level != NO_LEVEL else null)

func start_level(start_in_edit_mode:bool):
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return 
	if start_in_edit_mode and Singleton.SavedLevels.is_template_list:
		return 
	

	if is_dark:
		$TransitionRect.color = Color(0, 0, 0, 1)
	else :
		$TransitionRect.color = Color(1, 1, 1, 1)
	
	can_interact = false
	
	var level_info = levels[selected_level]
	Singleton.CurrentLevelData.level_data = level_info.level_data

	
	
	
	if not start_in_edit_mode:
		$TransitionRect.visible = true
		
		var total_shine_count: = 0
		for shine_details in level_info.shine_details:
			if shine_details["show_in_menu"]:
				total_shine_count += 1
		
		if total_shine_count > 1:
			Singleton.Music.change_song(Singleton.Music.last_song, 0)
			emit_signal("screen_change", "levels_screen", "shine_select_screen")
			return 

	

	
	if level_info.shine_details.size() == 1:
		level_info.selected_shine = 0
	$TransitionRect.visible = false
	
	var goal_scene = EDITOR_SCENE if start_in_edit_mode else PLAYER_SCENE
	var _connect = Singleton.SceneTransitions.connect("transition_finished", get_tree(), "change_scene_to", [goal_scene], CONNECT_ONESHOT)
	
	Singleton.SceneTransitions.play_transition_audio()
	
	if is_dark:
		Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Color(0, 0, 0, 0), Color(0, 0, 0, 1))
	else :
		Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Color(1, 1, 1, 0), Color(1, 1, 1, 1))

func set_level_code_panel(new_value:bool):
	level_list_panel.visible = not new_value
	level_code_panel.visible = new_value

func set_time_score_button(new_value:bool):
	single_time_score_panel.visible = not new_value
	button_time_scores.visible = new_value

func set_time_score_panel(new_value:bool):
	level_info_panel.visible = not new_value
	time_score_panel.visible = new_value

func set_control_buttons(is_enabled:bool)->void :
	button_play.disabled = not is_enabled
	button_edit.disabled = not is_enabled or Singleton.SavedLevels.is_template_list
	button_delete.disabled = not is_enabled or Singleton.SavedLevels.is_template_list
	button_reset.disabled = not is_enabled



func on_level_selected(index:int)->void :
	Singleton.SavedLevels.selected_level = index
	Singleton2.level = Singleton.SavedLevels.selected_level
	var level_info:LevelInfo = levels[Singleton.SavedLevels.selected_level]
	populate_info_panel(level_info)
	
	if double_click:
		start_level(false)

func on_button_back_pressed()->void :
	emit_signal("screen_change", "levels_screen", "main_menu_screen")

func on_button_add_pressed()->void :
	set_level_code_panel(true)

	button_code_cancel.grab_focus()


func on_button_new_level_pressed()->void :
	
	
	import(TEMPLATE_LEVEL)



func on_button_code_import_pressed()->void :
	var level_code = level_code_entry.text
	var also_level_code = OS.clipboard

	if level_code_util.is_valid(level_code):
		var level_info:LevelInfo = LevelInfo.new(level_code)
		add_level(level_info)
		level_code_entry.text = ""
		set_level_code_panel(false)
		return 
		
	if level_code_util.is_valid(also_level_code):
		var level_info:LevelInfo = LevelInfo.new(also_level_code)
		add_level(level_info)
		level_code_entry.text = ""
		set_level_code_panel(false)

func import(code):

	if level_code_util.is_valid(code):
		var level_info:LevelInfo = LevelInfo.new(code)
		add_level(level_info)
		level_code_entry.text = ""
		set_level_code_panel(false)
		return 

func on_button_code_cancel_pressed()->void :
	level_code_entry.text = ""
	set_level_code_panel(false)

func on_button_copy_code_pressed()->void :
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return 
	
	if Singleton.SavedLevels.is_template_list:
		
		Singleton.SavedLevels.is_template_list = false
		
		var tmp: = level_code_entry.text
		level_code_entry.text = levels[selected_level].level_code
		_pre_open_screen()
		on_button_code_import_pressed()
		level_code_entry.text = tmp
		
	else :
		var bytearray_code = levels[selected_level].level_code
		OS.clipboard = bytearray_code

func on_button_community_levels_pressed()->void :
	show_sample_levels = false
	_pre_open_screen()

func on_button_sample_levels_pressed()->void :
	show_sample_levels = true
	_pre_open_screen()


func on_button_play_pressed()->void :
	if not can_interact:
		return 
	start_level(false)

func on_button_edit_pressed()->void :
	toggle_dark_mode()
	if not can_interact:
		return 
	start_level(true)

func on_button_delete_pressed()->void :
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return 
	
	var level_code = levels[selected_level].level_code
	var level_info:LevelInfo = LevelInfo.new(level_code)
	
	pop_up_container.visible = true
	confirm_delete_window.set_level_name(level_info.level_name)
	confirm_delete_window.index_to_send = selected_level
	emit_signal("open_delete_confirmation_popup")

func on_button_reset_pressed()->void :
	var selected_level = Singleton.SavedLevels.selected_level
	if selected_level == NO_LEVEL:
		return 
	var dir = Directory.new()
	var level_info = levels[selected_level]
	var ghost_dir = "user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + ".127ghost"
	if dir.file_exists(ghost_dir):
		dir.remove(ghost_dir)
	level_info.reset_save_data()
	populate_info_panel(level_info)


func on_button_time_scores_pressed()->void :
	set_time_score_panel(true)

	button_close_time_scores.grab_focus()

func on_button_close_time_scores_pressed()->void :
	set_time_score_panel(false)

	
