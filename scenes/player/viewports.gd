extends HBoxContainer

onready var viewport_container1 = $ViewportContainer
onready var viewport_container2 = $ViewportContainer2

onready var viewport1 = $ViewportContainer/Viewport
onready var viewport2 = $ViewportContainer2/Viewport

onready var camera1 = $ViewportContainer/Viewport/CameraP1
onready var camera2 = $ViewportContainer2/Viewport/CameraP2

onready var world = $ViewportContainer/Viewport/World

onready var player1 = $ViewportContainer/Viewport/World/Character
onready var player2 = $ViewportContainer/Viewport/World/Character2

export var divider_path : NodePath
onready var divider = get_node(divider_path)

export var character_scene_path : String

var player1_spawn = Vector2(0, 0)
var player2_spawn = Vector2(0, 0)

func remove_player():
	if Singleton.PlayerSettings.number_of_players == 2:
		player2.position.y = -9999999999999
		viewport_container2.visible = false
		camera2.character_node = null
		player2.queue_free()
		Singleton.PlayerSettings.number_of_players = 1
		player1.number_of_players = Singleton.PlayerSettings.number_of_players
		
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		
		for child in world.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
			
			if child is Character:
				get_parent().character = get_parent().get_path_to(child)
			
		for child in viewport1.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
			
			if child is Camera2D:
				get_parent().camera = get_parent().get_path_to(child)
			
		for child in viewport_container1.get_children():
			child.get_parent().remove_child(child)
			get_parent().add_child(child)
		
		queue_free()

func add_player(): # boy do i love hacks
	if Singleton.PlayerSettings.number_of_players == 1:
		Singleton.PlayerSettings.number_of_players = 2
		player2 = load(character_scene_path).instance()
		player2.character = Singleton.PlayerSettings.player2_character
		player2.player_id = 1
		player2.name = "Character2"
		player2.add_collision_exception_with(player1)
		player1.add_collision_exception_with(player2)
		player1.number_of_players = Singleton.PlayerSettings.number_of_players
		player2.number_of_players = Singleton.PlayerSettings.number_of_players
		viewport1.add_child(player2)
		player2._ready()
		player2.load_in(Singleton.CurrentLevelData.level_data, Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area])
		camera2.character_node = player2
		player2.position = player2_spawn
		player2.spawn_pos = player2_spawn
		
		viewport_container1.visible = true
		viewport_container2.visible = true
		viewport2.size.x = 384
		viewport_container2.rect_size.x = 384
		viewport1.size.x = 384
		viewport_container1.rect_size.x = 384
		
		camera1.smoothing_enabled = false
		camera2.smoothing_enabled = false
		yield(get_tree(),"idle_frame")
		camera1.smoothing_enabled = true
		camera2.smoothing_enabled = true

func _ready():
	player1.character = Singleton.PlayerSettings.player1_character
	player2.character = Singleton.PlayerSettings.player2_character
	viewport2.world_2d = viewport1.world_2d
	player1.number_of_players = Singleton.PlayerSettings.number_of_players
	player2.number_of_players = Singleton.PlayerSettings.number_of_players
	for object in Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].objects:
		if object.type_id == 0:
			player1_spawn = object.properties[0]
			player1.spawn_pos = player1_spawn
		elif object.type_id == 5:
			player2_spawn = object.properties[0]
			player2.spawn_pos = player2_spawn
	if Singleton.PlayerSettings.number_of_players == 1:
		Singleton.PlayerSettings.number_of_players = 2
		remove_player()

func _process(_delta):
	if Singleton.PlayerSettings.number_of_players == 2 and Singleton.PlayerSettings.other_player_id == -1:
		#if Input.is_action_just_pressed("(disabled)copy_level"):
		#	remove_player()
			
		player1.controlled_locally = true
		player2.controlled_locally = true
	else:
		viewport_container2.visible = false
		viewport_container1.visible = true
		viewport1.size.x = 768
		viewport_container1.rect_size.x = 768
		viewport2.size.x = 0
		viewport_container2.rect_size.x = 0
		
		divider.visible = false
		if Input.is_action_just_pressed("(disabled)paste_level"):
			add_player()
