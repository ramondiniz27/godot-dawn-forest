extends KinematicBody2D
class_name Player

onready var player_sprite = get_node("Texture")

# Movement Variables
var velocity: Vector2  #(valor de  X,  valor de Y)
var landing: bool = false
var jump_count: int = 0

# Actions Variables
var attacking: bool = false
var defending: bool = false
var crouching:bool = false

var can_track_input:bool = true

# Gravity and Speed Variables
export(int) var speed
export(int) var jump_speed
export(int) var player_gravity

func _physics_process(delta: float):
	horizontal_moviment_env()
	vertical_movement_env()
	actions_env()
	gravity(delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	player_sprite.animate(velocity)
	

func horizontal_moviment_env() -> void:
	var input_direction: float  = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if can_track_input == false or attacking:
		velocity.x = 0
		return 
		
	velocity.x = input_direction * speed
	
func vertical_movement_env() -> void:
	var jump_condition = jump_count < 2 and can_track_input == true and not attacking
	if is_on_floor():
		jump_count = 0
		
	if Input.is_action_just_pressed("jump") and jump_condition:
		jump_count +=1
		velocity.y = jump_speed
	
func actions_env():
	attack()
	crouch()
	defense()
	pass
func attack() -> void:
	var attack_condition:bool = not attacking and not crouching and not defending
	if Input.is_action_just_pressed("attack") and attack_condition and is_on_floor():
		attacking = true
		player_sprite.normal_attack = true
	
func crouch() -> void:
	if Input.is_action_pressed("crouch") and is_on_floor() and not defending:
		crouching = true
		defending = false
		can_track_input = false
	elif not defending:
		crouching = false
		can_track_input = true
		player_sprite.crouching_off = true
	
	
func defense() -> void:
	if Input.is_action_pressed("defense") and is_on_floor() and not crouching:
		defending = true
		can_track_input = false
	elif not crouching:
		defending = false
		can_track_input = true
		player_sprite.shield_off = true
	
func gravity(delta: float) -> void:
	velocity.y += delta * player_gravity
	if velocity.y >= player_gravity:
		velocity.y = player_gravity
