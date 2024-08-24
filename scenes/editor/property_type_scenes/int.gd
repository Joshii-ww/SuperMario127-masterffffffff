extends LineEdit

func _ready():
	var _connect = connect("focus_exited", self, "update")
	
func update():
	if !text.is_valid_integer():
		text = "0"

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()
