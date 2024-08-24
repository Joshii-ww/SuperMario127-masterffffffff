extends Node

class_name Powerup

signal powerup_state_changed

var character: Character

export var id : String
export var music_id : int
export var is_invincible : bool
export var material : ShaderMaterial
export var time_left : float
export var play_temp_music : bool

func _ready():
	character = get_parent().get_parent() # This really isn't a great idea

func handle_update(delta: float):
	if character.powerup == self:
		_update(delta)
	_general_update(delta)

func apply_visuals():
	pass

func remove_visuals():
	pass

func toggle_visuals():
	pass

func _start(_delta, _play_temp_music: bool):
	pass

func _update(_delta):
	pass

func _general_update(_delta):
	pass

func _stop(_delta):
	pass
