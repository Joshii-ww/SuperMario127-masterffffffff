extends BaseButton

onready var hover_sound : AudioStreamPlayer = $HoverSound 
onready var click_sound : AudioStreamPlayer = $ClickSound

func _ready() -> void:
	var _connect
	_connect = connect("focus_entered", self, "on_focus_entered")
	_connect = connect("mouse_entered", self, "on_mouse_entered")
	_connect = connect("mouse_exited", self, "on_mouse_exited")
	_connect = connect("pressed", self, "on_pressed")

func on_mouse_entered() -> void:
	grab_focus()
	hover_sound.play()

func on_mouse_exited() -> void:
	release_focus()

func on_focus_entered() -> void:
	hover_sound.play()

func on_pressed() -> void:
	click_sound.play()
	get_parent().get_parent().visible = false
	get_parent().get_parent().get_parent().get_node("Hotkeys").visible = true
	Singleton2.disable_hotkeys = true
