extends KinematicBody2D

const GRAVITY = 150

var MAX_SPEED = 400
const ROT_SPEED = 2.5
const FRICTION = -0.8 #-0.65
var DEFAULT_THRUST = 400

var velocity = Vector2()
var acceleration = Vector2()

onready var thrust_ray = get_node("RayCast2D")

func _physics_process(delta):
	var THRUST = DEFAULT_THRUST
	if thrust_ray.is_colliding():
		var col_point = thrust_ray.get_collision_point()
		var distance = position.distance_to(col_point)
		THRUST += 6000/distance 
	print(THRUST)
	if Input.is_action_pressed("LEFT") and Input.is_action_pressed("RIGHT"):
		acceleration = Vector2()
	else:
		acceleration = Vector2(0, -THRUST).rotated(rotation)
	if Input.is_action_pressed("LEFT"):
		rotation -= ROT_SPEED * delta
	if Input.is_action_pressed("RIGHT"):
		rotation += ROT_SPEED * delta

	acceleration += velocity * FRICTION
	acceleration.y += GRAVITY
	velocity += acceleration * delta
	# velocity = velocity.clamped(MAX_SPEED)
	var col = move_and_collide(velocity * delta)
	if col:
		var reflect = col.remainder.bounce(col.normal)
		velocity = velocity.bounce(col.normal)*0.4
		move_and_collide(reflect)
