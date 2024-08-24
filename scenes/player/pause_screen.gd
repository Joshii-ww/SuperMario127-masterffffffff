extends Control

export var darken_color : Color

export var character_node_path : NodePath
onready var character_node = get_node(character_node_path)

export var character2_node_path : NodePath
onready var character2_node = get_node(character2_node_path)

onready var topbar = $Top

onready var bottombar = $Bottom
onready var resume_button = $Bottom/Buttons/ResumeButton
onready var retry_button = $Bottom/Buttons/RetryButton
onready var quit_button = $Bottom/Buttons/QuitButton
onready var darken = $Darken

onready var shine_info = $ShineInfo
onready var multiplayer_options = $MultiplayerOptions
onready var controls_options = $ControlsOptions
onready var shinecount = $ShineInfo/ShineCount
onready var sccount = $ShineInfo/SCCount

onready var fade_tween = $TweenFade
onready var topbar_tween = $TweenTopbar
onready var bottombar_tween = $TweenBottombar
onready var info_tween = $TweenShineInfo

onready var nextbutton = $ShineInfo/NextShine
onready var prevbutton = $ShineInfo/PrevShine

export var chat_path : NodePath
onready var chat_node = get_node(chat_path)

var paused := false
var levels = Singleton.SavedLevels.levels

#shine information variables
var shine_offset = 0
var selected_level = Singleton.SavedLevels.selected_level
var shineDetails = Singleton.SavedLevels.get_current_levels()[selected_level].shine_details

func _ready():
	# You want it to be visible for editing, but that causes a bug, which this fixes
	visible = false
	scrollcheck()
	
	if Singleton.ModeSwitcher.button.playtesting:
		quit_button.disabled = true
	
	var _connect = resume_button.connect("pressed", self, "toggle_pause")
	_connect = retry_button.connect("pressed", self, "retry")
	_connect = quit_button.connect("pressed", self, "quit_to_menu")
	_connect = nextbutton.connect("pressed", self, "next_shine")
	_connect = prevbutton.connect("pressed", self, "prev_shine")
	Singleton.FocusCheck.is_ui_focused = false
	
	darken.modulate = Color(0, 0, 0, 0)
	topbar.rect_position = Vector2(0, -70)
	bottombar.rect_position = Vector2(768, 500)
	shine_info.rect_scale = Vector2(0, 0)

	Singleton.CurrentLevelData.can_pause = false

	set_process(false)

	update_shine_info()

	# Wait before enabling pausing, so that the game can't enter the strangest pause state
	yield(get_tree().create_timer(0.2), "timeout")
	Singleton.CurrentLevelData.can_pause = true

func populate_info_panel(level_info : LevelInfo = null) -> void:

		# Only count shine sprites that have show_in_menu on
		var total_shine_count := 0
		var collected_shine_count := 0

		for shine_details in level_info.shine_details:
			total_shine_count += 1
			if level_info.collected_shines[str(shine_details["id"])]:
				collected_shine_count += 1

		shinecount.text = "%s/%s" % [collected_shine_count, total_shine_count]

		var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
		sccount.text = "%s/%s" % [collected_star_coin_count, level_info.collected_star_coins.size()]
func _unhandled_input(event):
	if Singleton.CurrentLevelData.can_pause and event.is_action_pressed("pause") and !(character_node.dead or (Singleton.PlayerSettings.number_of_players != 1 and character2_node.dead)):
		toggle_pause()

func toggle_pause():
	var is_not_transitioning : bool = !Singleton.SceneTransitions.transitioning
	# if the mode switcher button is invisible, then we're not in the editor at all
	var is_not_switching_modes : bool = !Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled or Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible
	if is_not_transitioning and is_not_switching_modes and !Singleton.PhotoMode.enabled and paused == get_tree().paused and get_parent().get_node("SignText").modulate.a <= 0.005:
		if !shine_info.visible:
			$ControlsOptions.reset() # for resetting the Wait... state
			$ControlsOptions/ControlBindingWindow/Contents/ScrollContainer/BindingBoxContainer.reset()
			$ControlsOptions/ControlBindingWindow.close()
			SettingsSaver.save()
			if controls_options.visible:
				controls_options.visible = false
				shine_info.visible = true
			else:
				multiplayer_options.visible = false
				shine_info.visible = true
		resume_button.focus_mode = 0
		
		Singleton.CurrentLevelData.can_pause = false
		get_tree().paused = true if !self.visible and Singleton.PlayerSettings.other_player_id == -1 else false
		paused = get_tree().paused
		# if we're visible and toggling pause, that means we need to fade out back to gameplay
		if self.visible:
			Singleton.FocusCheck.is_ui_focused = false
			chat_node.visible = true
			fade_tween.interpolate_property(darken, "modulate",
			null, Color(0, 0, 0, 0), 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			topbar.rect_position, Vector2(0, -70), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			bottombar.rect_position, Vector2(768, 500), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			shine_info.rect_scale, Vector2(0, 0), 0.20,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
			
			self.visible = false
			Singleton.CurrentLevelData.can_pause = true

			# disable process at the end of the transition so the time score updates during it
			set_process(false)
		else:
			# enable process before the transition starts so the time score updates during it
			set_process(true)

			Singleton.FocusCheck.is_ui_focused = true
			self.visible = true
			chat_node.visible = false
			fade_tween.interpolate_property(darken, "modulate",
			null, darken_color, 0.20,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
			fade_tween.start()
			
			topbar_tween.interpolate_property(topbar, "rect_position",
			topbar.rect_position, Vector2(0, 0), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			topbar_tween.start()
			
			bottombar_tween.interpolate_property(bottombar, "rect_position",
			bottombar.rect_position, Vector2(768, 400), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			bottombar_tween.start()
			
			info_tween.interpolate_property(shine_info, "rect_scale",
			shine_info.rect_scale, Vector2(1, 1), 0.20,
			Tween.TRANS_CIRC, Tween.EASE_OUT)
			info_tween.start()
			
			yield(fade_tween, "tween_completed")
			
			Singleton.CurrentLevelData.can_pause = true
	
func retry():
	SettingsSaver.save()
	retry_button.focus_mode = 0
	if !character_node.dead:
		character_node.kill("reload")
	elif is_instance_valid(character2_node):
		character2_node.kill("reload")

func quit_to_menu() -> void:
	# music is stopped while paused, but there's a frame where it starts playing again after the transition, just kill it here to stop that
	Singleton.Music.change_song(Singleton.Music.last_song, 0)
	Singleton.MenuVariables.quit_to_menu_with_transition("levels_screen")

func update_shine_info():
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	
	var level_name : Label = shine_info.get_node("LevelName")
	var level_name_backing : Label = shine_info.get_node("LevelName/LevelNameBacking")
	var shine_description : RichTextLabel = shine_info.get_node("ShineDescription")
	var shine_name : RichTextLabel = shine_info.get_node("ShineName")
	
	level_name.text = level_info.level_name 
	level_name_backing.text = level_info.level_name
	
	if level_info.selected_shine == -1: # This can happen if there are no shine sprites in the level
		shine_description.bbcode_text = "[center]There are no shine sprites in this level.[/center]"
		shine_name.bbcode_text = "[center]No shine sprite selected[/center]"
	else:
		var selected_shine_info = level_info.shine_details[level_info.selected_shine + shine_offset]
		shine_description.bbcode_text = "[center]%s[/center]" % selected_shine_info["description"] 
		shine_name.bbcode_text = "[center]%s[/center]" % selected_shine_info["title"]
		
func _process(delta):
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	populate_info_panel(level_info)

#changes pause menu description to previous shine info
func prev_shine():
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	
	if level_info.selected_shine + shine_offset >= 1:
		shine_offset -= 1
		
	update_shine_info()
	scrollcheck()
	

#changes pause menu description to next shine info
func next_shine():	
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if (level_info.selected_shine + shine_offset) < (shineDetails.size()-1):
		shine_offset += 1 
	else:
		shine_offset = shine_offset
	
	update_shine_info()
	scrollcheck()
	
func scrollcheck():
	var level_info = Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level]
	if (level_info.selected_shine + shine_offset) < (shineDetails.size()-1):
		nextbutton.show()
	else:
		nextbutton.hide()

	if level_info.selected_shine + shine_offset >= 1:
		prevbutton.show()
	else:
		prevbutton.hide()
