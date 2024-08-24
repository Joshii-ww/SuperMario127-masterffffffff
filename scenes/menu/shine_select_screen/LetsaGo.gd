extends Node

export var mario_voices := []
export var luigi_voices := []
export var is_p2 := false
export var array_index : int

onready var audio_player : AudioStreamPlayer = $LetsaGoPlayer

func play():
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var player : int = Singleton.PlayerSettings.player2_character if is_p2 else Singleton.PlayerSettings.player1_character 
	var voices := []
	match player:
		0:
			voices = mario_voices
		1:
			voices = luigi_voices
	
	if voices.size() > 0:
		if !is_p2:
			array_index = rng.randi_range(0, voices.size() - 1)
		audio_player.stream = voices[array_index]
	
	audio_player.play()
