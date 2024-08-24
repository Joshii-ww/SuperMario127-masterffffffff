extends Control

onready var line_edit = $LineEdit

func _ready():
	line_edit.text = Singleton.CurrentLevelData.level_data.name
	var _connect = line_edit.connect("focus_exited", self, "update_name")
	
func update_name():
	Singleton.CurrentLevelData.level_data.name = line_edit.text

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		line_edit.release_focus()
