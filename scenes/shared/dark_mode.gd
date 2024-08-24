extends Control

onready var button : Button = $Box

var value : bool = false

func _ready():
	value = Singleton2.dark_mode
	_update_text()
	var _connect = button.connect("pressed", self, "_update_value")

func _update_value():
	value = !value
	Singleton2.dark_mode = value
	Singleton2.toggle_dark_mode()
	_update_text()

func _update_text():
	button.text = "True" if value else "False"
