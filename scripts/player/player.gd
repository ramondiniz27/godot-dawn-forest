extends KinematicBody2D
class_name Player

onready var player_sprite = get_node("Texture")
onready var wall_ray: RayCast2D = get_node("WallRay")
onready var stats: Node = get_node("Stats")

# Movement Variables
var velocity: Vector2  #(valor de  X,  valor de Y)
var landing: bool = false
var on_wall: bool = false
var direction: int = 1
var jump_count: int = 0

# Actions Variables
var attacking: bool = false
var defending: bool = false
var crouching:bool = false
var on_hit:  bool = false
var dead: bool = false

var can_track_input:bool = true
var not_on_wall: bool = true

# Gravity and Speed Variables
export(int) var speed
export(int) var jump_speed
export(int) var player_gravity

# Gravity for Wall Jump
export(int) var wall_jump_speed
export(int) var wall_gravity
export(int) var wall_impulse_speed

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
	if is_on_floor() or is_on_wall():
		jump_count = 0
		
	if Input.is_action_just_pressed("jump") and jump_condition:
		jump_count +=1
		if next_to_wall() and not is_on_floor():
			velocity.y = wall_jump_speed
			velocity.x = wall_impulse_speed * direction
		else:
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
		stats.shielding = false
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
		stats.shielding = false
	elif not crouching:
		defending = false
		can_track_input = true
		player_sprite.shield_off = true
	
func gravity(delta: float) -> void:
	if next_to_wall():
		velocity.y += wall_gravity * delta
		if velocity.y >= wall_gravity:
			velocity.y += wall_gravity
	else:
		velocity.y += delta * player_gravity
		if velocity.y >= player_gravity:
			velocity.y = player_gravity
		
func next_to_wall() -> bool:
	if wall_ray.is_colliding() and not is_on_floor():
		if not_on_wall:
			velocity.y = 0
			not_on_wall = false
		return true
	else:
		not_on_wall = true
		return false
