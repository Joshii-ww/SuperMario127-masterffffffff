extends Control

onready var button : Button = $Box

var value : bool = false

func _ready():
	var _connect = button.connect("pressed", self, "_update_value")

func _update_value():
	get_parent().get_node("AreasWindow").open()

