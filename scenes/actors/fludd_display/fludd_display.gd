extends Node2D
 
export var char_path : NodePath
var character : Character

onready var ui = $CanvasLayer/FluddUI
onready var label = $CanvasLayer/FluddUI/Label
onready var label_shadow = $CanvasLayer/FluddUI/LabelShadow
onready var water_texture = $CanvasLayer/FluddUI/WaterTexture
onready var water_shadow = $CanvasLayer/FluddUI/WaterShadow
onready var tween = $CanvasLayer/FluddUI/Tween

var interpolation_speed = 15

export var material_0 : ShaderMaterial
export var material_1 : ShaderMaterial

export var subtraction_amount = 71
export var default_x_pos = 693
export var multiplayer_x_pos = 309

var shown = false
var last_shown = false

var current_health = 8

# The code I added to make the new UI work is not very well done, but
# it would be a waste of time and effort to try to clean it up as I would 
# have to rewrite the whole script, none of this is well made code.

# And that wouldn't make much of a difference, the whole game is 
# being rewritten already. I doubt anyone would need to work much
# with this code between now, and after the rewrite is finished.

func _ready():
	character = get_node(char_path)
	if (character.player_id == 0) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
		ui.rect_position.x = multiplayer_x_pos
	elif (character.player_id == 1) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
		ui.rect_position.x = default_x_pos
	else:
		ui.rect_position.x = default_x_pos
		
	if character.player_id == 0:
		water_texture.material = material_0
		water_shadow.material = material_0
	else:
		water_texture.material = material_1
		water_shadow.material = material_1

func _process(delta):
	if is_instance_valid(character):
		if character is Character:
			ui.value = character.stamina
			label.text = str(int(character.fuel)) + "%"
			label_shadow.text = label.text
			
			var water_height = water_texture.material.get_shader_param("water_height")
			water_height = lerp(water_height, 1.0 - (character.fuel / 100.0), delta * interpolation_speed)
			water_texture.material.set_shader_param("water_height", water_height)
			shown = character.nozzle != null

			if character.health == 8:
				var new_x_pos = default_x_pos
				if (character.player_id == 0) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
					new_x_pos = multiplayer_x_pos
				ui.rect_position.x = lerp(ui.rect_position.x, new_x_pos, delta * 7)
			else:
				var new_x_pos = default_x_pos - subtraction_amount
				if (character.player_id == 0) and Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
					new_x_pos = multiplayer_x_pos - subtraction_amount
				ui.rect_position.x = lerp(ui.rect_position.x, new_x_pos, delta * 7)
	else:
		shown = false
		
	if shown and !last_shown:
		tween.interpolate_property(ui, "rect_position:y",
			ui.rect_position.y, 15, 0.50,
			Tween.TRANS_BACK, Tween.EASE_OUT)
		tween.start()
	elif !shown and last_shown:
		tween.interpolate_property(ui, "rect_position:y",
			ui.rect_position.y, -60, 0.50,
			Tween.TRANS_BACK, Tween.EASE_IN)
		tween.start()
	
	last_shown = shown
	
	if Singleton.PhotoMode.enabled:
		ui.visible = false
	else:
		ui.visible = true
