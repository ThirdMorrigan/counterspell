extends CharacterBody3D

@onready var main_camera = $main_camera

@export var SPEED : float = 5.0
@export var FRICTION : float = 20.0
@export var ACCEL : float = 60.0
const STOP_SPEED : float = 0.5

@export var HEIGHT : float = 1.8
@export var HEIGHT_CROUCH : float = 1.0
var current_height : float
var crouching : bool = false

@export var JUMP_VELOCITY : float = 3.5

@export var SENSITIVITY : float = 1.5
const MOUSE_SCALE : float = PI/3600

var speed : float

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	current_height = HEIGHT
	$stand_check.position.y = HEIGHT_CROUCH
	$stand_check.target_position.y = HEIGHT - HEIGHT_CROUCH
	speed = SPEED
	set_height(HEIGHT)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_look(-event.relative)

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity:
		var flat_velocity = velocity - Vector3.UP*velocity.y
		$leading_edge.global_position = position + flat_velocity.normalized()*0.2 + Vector3.UP

	if Input.is_action_just_pressed("J") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	crouching = Input.is_action_pressed("C") or $stand_check.is_colliding()
	update_height(delta)

	var input_dir = Input.get_vector("M_L", "M_R", "M_F", "M_B")
	var wish_3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	friction(delta, input_dir)
	
	if input_dir:
		if is_on_floor():
			accelerate(wish_3,delta)
		else:
			accelerate_air(wish_3,delta)
			

	move_and_slide()

func set_height(new:float):
	$visuals.mesh.height = new
	$visuals.position.y = new*0.5
	$main_camera.position.y = new - 0.35
	$cap.shape.height = new - 0.1
	$cap.position.y = new*0.5 + 0.05
	
	current_height = new
	

func update_height(delta:float):
	var target_height = HEIGHT_CROUCH if crouching else HEIGHT
	if current_height != (target_height):
		var new_height = lerp(current_height, target_height, 10.0*delta)
		if abs(new_height-target_height) <= 0.005:
			new_height = target_height
		if !is_on_floor():
			position.y -= new_height - current_height
		set_height(new_height)

func mouse_look(by:Vector2):
	by *= MOUSE_SCALE * SENSITIVITY
	rotate_y(by.x)
	main_camera.rotate_x(by.y)

func friction(delta:float, moving:Vector2):
	if is_on_floor():
		var current_speed = velocity.length()
		var current_dir = velocity/current_speed if current_speed > 0.0 else Vector3.ZERO
		var edge_scale = (1.0 if $leading_edge.is_colliding() or moving else 3.0)
		var slow_by = FRICTION*delta*edge_scale if current_speed > STOP_SPEED or moving else current_speed
		velocity -= current_dir*slow_by

func accelerate(wish_3:Vector3,delta:float):
	var vel_h = velocity
	vel_h.y = 0.0
	var current_speed = vel_h.dot(wish_3)
	var add_speed = clamp(delta*ACCEL, 0.0, speed-current_speed)
	velocity += wish_3 * add_speed

func accelerate_air(wish_3:Vector3,delta:float):
	var vel_h = velocity
	vel_h.y = 0.0
	var current_speed = vel_h.dot(wish_3)
	var add_speed = clamp(delta*ACCEL*0.15, 0.0, speed*0.75-current_speed)
	velocity += wish_3 * add_speed
