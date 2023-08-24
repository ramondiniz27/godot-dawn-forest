extends Sprite
class_name PlayerTexture

export(NodePath) onready var animation = get_node(animation) as AnimationPlayer
export(NodePath) onready var player = get_node(player) as KinematicBody2D

var normal_attack:bool = false
var suffix: String = "_right"
var shield_off: bool = false
var crouching_off: bool = false

func animate(direction: Vector2) -> void:
	verify_position(direction)
	
	if player.on_hit or player.dead:
		hit_behavior()
	elif player.attacking or player.defending or player.crouching or player.next_to_wall():
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.landing == true:
		animation.play("landing")
		player.set_physics_process(false)
	else:
	 horizontal_behavior(direction)
	
	
func verify_position(direction: Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "_right"
		player.direction = -1
		position = Vector2.ZERO
		player.wall_ray.cast_to = Vector2(13.2,0)
	elif direction.x < 0:
		flip_h = true
		suffix = "_left"
		player.direction = 1
		position = Vector2(-2, 0)
		player.wall_ray.cast_to = Vector2(-13.2,0)

func action_behavior() -> void:
	if player.next_to_wall():
		animation.play("wall_slide")
	elif player.attacking == true and normal_attack:
		animation.play("attack" + suffix)
	elif player.defending and shield_off:
		animation.play("shield")
		shield_off = false
	elif player.crouching and crouching_off:
		animation.play("crouch")
		crouching_off = false
		

func vertical_behavior(direction: Vector2) -> void:
	if direction.y > 0:
		player.landing = true
		animation.play('fall')
	elif direction.y < 0:
		animation.play('jump')
		
func horizontal_behavior(direction: Vector2) -> void: 
	if direction.x != 0:
		animation.play("run")
		
	else:
		animation.play("idle")
		
func hit_behavior() -> void:
	player.set_physics_process(false)
	
	if(player.dead):
		animation.player("dead")
	elif player.on_hit:
		animation.play("hit")	
	pass

func on_animation_finished(anim_name):
	match anim_name:
		"landing": 
			player.landing = false
			player.set_physics_process(true)
		"attack_left":
			normal_attack = false
			player.attacking = false
		"attack_right":
			normal_attack = false
			player.attacking = false
		"hit":
			player.on_hit = false
			player.set_physics_process(true)
			
			if player.defending:
				player.set_physics_process("shield")
			if player.crouching:
				animation.play("crouch")
