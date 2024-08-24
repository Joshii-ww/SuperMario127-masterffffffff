extends State

class_name GroundPoundEndState

var end_timer = 0
var jump_timer = 0
var particle_timer = 0

func _ready():
	priority = 4
	attack_tier = 1
	disable_turning = true
	disable_animation = true
	disable_movement = true
	override_rotation = true
	blacklisted_states = []

func _start_check(_delta):
	return false

func _start(_delta):
	particle_timer = 0.2
	character.gp_particles1.emitting = true
	character.gp_particles2.emitting = true
	end_timer = 0.3
	character.velocity.x = 0
	var sprite = character.sprite
	if character.facing_direction == 1:
		sprite.animation = "groundPoundEndRight"
	else:
		sprite.animation = "groundPoundEndLeft"
	character.sound_player.play_gp_hit_sound()

func _stop(delta):
	particle_timer = 0
	character.big_attack = false
	character.heavy = false
	if jump_timer > 0:
		character.current_jump = 1
		character.set_state_by_name("JumpState", delta)
		character.gp_particles1.emitting = false
		character.gp_particles2.emitting = false
	else:
		character.current_jump = 0
		character.jump_animation = 0
		character.set_state_by_name("BounceState", delta)
		character.gp_particles1.emitting = false
		character.gp_particles2.emitting = false
		character.position.y -= 1
		character.velocity.y = -150

func _stop_check(_delta):
	return end_timer <= 0 or jump_timer > 0
	
func _general_update(delta):
	if end_timer > 0:
		end_timer -= delta
		if end_timer <= 0:
			end_timer = 0
	if jump_timer > 0:
		jump_timer -= delta
		if jump_timer <= 0:
			jump_timer = 0
	if particle_timer > 0:
		particle_timer -= delta
		if particle_timer <= 0:
			particle_timer = 0
			character.gp_particles1.emitting = false
			character.gp_particles2.emitting = false
	if character.inputs[2][1]:
		jump_timer = 0.15
