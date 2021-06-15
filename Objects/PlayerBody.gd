extends KinematicBody2D

const GRAVITY = 0

var MAX_SPEED = 400
const ROT_SPEED = 2.5
const FRICTION = -0.8 #-0.65
var DEFAULT_THRUST = 400

var velocity = Vector2()
var acceleration = Vector2()

var wheel_base = 100  
var engine_power = 800  

var steering_angle = 40
var steer_angle

var friction = -0.05
var drag = -0.0015

var slip_speed = 400 

var traction = 0.01  

onready var thrust_ray = get_node("RayCast2D")


func get_input():
	var turn = 0
	if Input.is_action_pressed("RIGHT"):
		turn -= 1
	if Input.is_action_pressed("LEFT"):
		turn += 1
	steer_angle = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("ACCELERATE"):
		acceleration = transform.x * engine_power


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	front_wheel += velocity * delta
	rear_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	rotation = new_heading.angle()


func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	if velocity.length() < 100:
		friction_force *= 3
	acceleration += drag_force + friction_force


func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	velocity = move_and_slide(velocity)
