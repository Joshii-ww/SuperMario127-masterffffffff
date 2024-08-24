extends Screen

onready var button_campaign:Button = $Panel / VBoxContainer / ButtonCampaign
onready var button_levels:Button = $Panel / VBoxContainer / ButtonLevels
onready var button_search:Button = $Panel / VBoxContainer / ButtonSearch
onready var button_templates:Button = $Panel / VBoxContainer / ButtonTemplates
onready var button_options:Button = $Panel / VBoxContainer / ButtonOptions
onready var button_quit:Button = $Panel / ButtonQuit
onready var button_login:Button = $Panel / ButtonLogin
onready var button_skip = $Control / Skip
onready var button_speed = $Control / Speed
onready var credits = $Control / AnimationPlayer
onready var credits2 = $Control / AnimationPlayer2
onready var credits3 = $Control / AnimationPlayer3
onready var error_window = $ErrorWindow

onready var timer = $CooldownTimer

onready var lss_icon = preload("res://assets/misc/LSS.svg")

const EDITOR_SCENE:PackedScene = preload("res://scenes/editor/editor.tscn")


func _ready()->void :
	$Control / ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if UserInfo.username != "":
		button_login.text = "Logged in as " + UserInfo.username
	Singleton2.crash = false
	
	var _connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_templates.connect("pressed", self, "on_button_templates_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_search.connect("pressed", self, "on_button_search_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")
	_connect = button_login.connect("pressed", self, "on_button_login_pressed")
	_connect = button_campaign.connect("pressed", self, "on_button_credits_pressed")
	_connect = button_skip.connect("pressed", self, "on_button_skip_pressed")
	_connect = button_speed.connect("pressed", self, "on_button_speed_pressed")
	





func _input(_event:InputEvent)->void :
	if not can_interact or get_focus_owner() != null:
		return 
	
	if Input.is_action_just_pressed("ui_up"):
		button_quit.grab_focus()
	elif Input.is_action_just_pressed("ui_down"):
		button_campaign.grab_focus()
	elif Input.is_action_just_pressed("ui_left"):
		pass
	elif Input.is_action_just_pressed("ui_right"):
		pass

func on_button_search_pressed()->void :
	emit_signal("screen_change", "main_menu_screen", "search_screen")
	
func _process(delta):
	pass
	
func on_button_levels_pressed()->void :
	if timer.time_left > 0:
		return 
	if Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = false
		
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_templates_pressed()->void :
	if timer.time_left > 0:
		return 
	if not Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = true
		
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_options_pressed()->void :
	if timer.time_left > 0:
		return 
	if not Singleton.SavedLevels.is_template_list:
		Singleton.SavedLevels.is_template_list = true
		
		Singleton.SavedLevels.selected_level = Singleton.SavedLevels.NO_LEVEL
	timer.start()
	emit_signal("screen_change", "main_menu_screen", "options_screen")

func on_button_quit_pressed()->void :
	get_tree().quit()
	
func on_button_speed_pressed()->void :
	if credits.playback_speed == 1:
		button_speed.text = "Speed (1x)"
		credits.playback_speed = 5
	else :
		button_speed.text = "Speed (5x)"
		credits.playback_speed = 1
		
func on_button_skip_pressed()->void :
	Singleton.Music.stop_temporary_music()
	credits.play("skip")
	$Control / ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func on_button_credits_pressed()->void :
	Singleton.Music.play_temporary_music(66, 50)
	credits3.play("Pasted Animation")
	credits.play("roll")
	var _connect = credits.connect("animation_finished", self, "on_roll_finished")
	credits2.play("button in")
	$Control / ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP

func on_roll_finished(anim_name):
	if anim_name == "roll":
		Singleton.Music.stop_temporary_music()
		$Control / ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
