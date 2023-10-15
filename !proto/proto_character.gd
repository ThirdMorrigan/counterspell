extends CharacterBody3D

@onready var main_camera = $main_camera

@export var SPEED : float = 5.0
@export var FRICTION : float = 20.0
@export var ACCEL : float = 60.0
const STOP_SPEED : float = 0.5

@export var JUMP_VELOCITY : float = 4.5

@export var SENSITIVITY : float = 1.5
const MOUSE_SCALE : float = PI/3600

var speed : float

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	speed = SPEED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_look(-event.relative)

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("J") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir = Input.get_vector("M_L", "M_R", "M_F", "M_B")
	var wish_3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	friction(delta)
	
	if input_dir:
		if is_on_floor():
			accelerate(wish_3,delta)
		else:
			accelerate_air(wish_3,delta)
			

	move_and_slide()

func mouse_look(by:Vector2):
	by *= MOUSE_SCALE * SENSITIVITY
	rotate_y(by.x)
	main_camera.rotate_x(by.y)

func friction(delta:float):
	if is_on_floor():
		var current_speed = velocity.length()
		var current_dir = velocity/current_speed if current_speed > 0.0 else Vector3.ZERO
		var slow_by = FRICTION*delta if current_speed > STOP_SPEED else current_speed
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
	var add_speed = clamp(delta*ACCEL*0.1, 0.0, speed*0.75-current_speed)
	velocity += wish_3 * add_speed
