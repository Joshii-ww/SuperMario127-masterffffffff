extends GameObject


#-------------------------------- GameObject logic -----------------------

var parts := 4
var last_parts := 4

var start_offset := 0
var start_percentage := 0
var last_start_percentage := 0

const MT_BACK_FORTH = 0
const MT_RESET = 1
const MT_ONCE = 2
const MT_LOOP = 3


var move_type := MT_BACK_FORTH
var touch_start := false

var end_position : Vector2
var last_end_position : Vector2

var max_speed := 1.0
onready var blend := pow(0.95, 120 * fps_util.PHYSICS_DELTA)

var curve = Curve2D.new()
var custom_path = Curve2D.new()

var disappears : bool = true
var inverted : bool = false

func _set_properties():
	savable_properties = ["parts", "max_speed", "curve", "move_type", "touch_start", "start_offset", "disappears", "inverted", "custom_path"]
	editable_properties = ["parts", "max_speed", "move_type", "touch_start", "start_offset", "inverted", "custom_path"]
	
func _set_property_values():
	set_property("parts", parts)
	set_property("max_speed", max_speed)
	set_property("curve", curve)
	set_property("end_position", end_position)
	set_property("move_type", move_type)
	set_property("touch_start", touch_start)
	set_property("start_offset", start_offset)
	set_property("disappears", disappears)
	set_property("inverted", inverted)
	set_property("custom_path", curve)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)

func _process(_delta):
	if parts != last_parts:
		platform.set_parts(parts)
		if(mode==1):
			set_sprite_parts(start_sprite_node.get_child(0))
			set_sprite_parts(end_sprite_node.get_child(0))

		last_parts = parts
	if curve != path.curve:
		path.curve = curve
		
	
	

#-------------------------------- platform logic -----------------------

onready var platform = $OnOffTouchLiftPlatform
onready var path_follower = $Path2D/PathFollow2D
onready var path = $Path2D
onready var platform_sprite = $OnOffTouchLiftPlatform/Sprite

export var circle_texture : Texture

var speed := 1.0
var loop_offset := 0.0
var linear_offset := 0.0
var time_alive = 0

var activated = false

onready var start_sprite_node : Node2D
onready var end_sprite_node : Node2D

const line_color = Color(1, 1, 1, 0.5)
const transparent_color : Color = Color(1, 1, 1, 0.5)

onready var left_width = platform_sprite.patch_margin_left
onready var right_width = platform_sprite.patch_margin_right
onready var part_width = 6

onready var frozen = false

func _ready():
	activated = !touch_start
	
	if(!disappears && inverted):
		frozen = true
		
	platform.collision_shape.disabled = !enabled
	platform.platform_area_collision_shape.disabled = !enabled
	
	platform.platform_area_collision_shape.get_parent().connect("body_entered", self, "_on_touch_area_entered")
	if curve.get_point_count() == 0:
		curve.add_point(Vector2())
		curve.add_point(Vector2(0, -64))
	if curve == null and path.curve == null:
		path.curve = Curve2D.new()
		path.curve.add_point(Vector2())
		path.curve.add_point(Vector2(0,-64))
		
		set_property("curve", path.curve)
	elif path.curve == null:
		path.curve = curve
	elif curve == null:
		set_property("curve", path.curve)
	
	platform.set_parts(parts)
	
	linear_offset = start_offset
	loop_offset = start_offset
	path_follower.offset = start_offset
	
	platform.set_sync_to_physics(true)
	if(mode==1):
		# Disable to fix rotation issues.
		platform.set_sync_to_physics(false)
		platform.modulate = transparent_color
		
		start_sprite_node = Node2D.new()
		start_sprite_node.add_child(platform_sprite.duplicate())

		#end_sprite.add_child(platform_sprite)
		add_child(start_sprite_node)
		
		end_sprite_node = Node2D.new()
		end_sprite_node.add_child(platform_sprite.duplicate())
		end_sprite_node.modulate = transparent_color
		add_child(end_sprite_node)
		
		set_property("end_position", path.curve.get_point_position(path.curve.get_point_count()-1)/32)

func set_sprite_parts(sprite):
	sprite.rect_position.x = -(left_width + (part_width * parts) + right_width) / 2
	sprite.rect_size.x = left_width + right_width + part_width * parts

func _draw():
	if mode == 1:
		draw_polyline(path.curve.get_baked_points(), line_color, 2.0)
	else:
		for offset in range(0,path.curve.get_baked_length(), 10.0):
			var pos : Vector2 = path.curve.interpolate_baked(offset)
			draw_texture_rect(circle_texture, Rect2(pos - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), false, Color.darkgray)

func _physics_process(delta):
	if(!activated || frozen):
		return
	_set_platform_pos()

func _set_platform_pos():
	linear_offset += speed * max_speed * 120 * fps_util.PHYSICS_DELTA

	if move_type != MT_LOOP:
		linear_offset = clamp(linear_offset, 0.0, path.curve.get_baked_length()-0.01) #so the 

	loop_offset = lerp(linear_offset, loop_offset, blend) #loop_offset * blend + linear_offset * (1 - blend)
	
	path_follower.offset = fmod(loop_offset, path.curve.get_baked_length())
	
	if speed < 0.0 and path_follower.offset <= 2.0:
		linear_offset = 0.0
		speed = -speed
	
	elif move_type != MT_LOOP and speed > 0.0 and path_follower.offset >= path.curve.get_baked_length() - 2.0:
		linear_offset = path.curve.get_baked_length()
		reached_end()
		
		if !activated:
			return
	
	if mode != 1:
		platform.set_position(path_follower.position)
	else:
		platform.position = path_follower.position

func reached_end() -> void:
	match move_type:
		MT_BACK_FORTH:
			speed = -speed
		MT_RESET:
			platform.cancel_momentum = true
			$AnimationPlayer.play("Reset")
		MT_ONCE:
			activated = false

func _on_touch_area_entered(body):
	if body is Character:
		activated = true

func reset_platform():
	linear_offset = 0.0
	loop_offset = 0.0
	path_follower.offset = 0.0
	
	platform.set_collision_layer_bit(4, false)
	platform.position = path_follower.position
	activated = !touch_start
	
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	platform.set_collision_layer_bit(4, true)
