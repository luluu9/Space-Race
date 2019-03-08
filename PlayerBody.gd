extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _physics_process(delta):
#	var force = Vector2(0, -1)
#	if Input.is_action_pressed("LEFT") and Input.is_action_just_pressed("RIGHT"):
#		pass
#	elif Input.is_action_pressed("LEFT"):
#		force.x = -1
#		self.rotation -= deg2rad(1)
#	elif Input.is_action_pressed("RIGHT"):
#		force.x = 1
#		self.rotation += deg2rad(1)
#	move_and_collide(force.rotated(self.rotation)*200*delta)

const MAX_SPEED = 400
const ROT_SPEED = 3.5
const FRICTION = -0.65
var THRUST = 600

var velocity = Vector2()
var acceleration = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("LEFT") and Input.is_action_pressed("RIGHT"):
		acceleration = Vector2()
	else:
		acceleration = Vector2(0, -THRUST).rotated(rotation)
	if Input.is_action_pressed("LEFT"):
		rotation -= ROT_SPEED * delta
	if Input.is_action_pressed("RIGHT"):
		rotation += ROT_SPEED * delta

	acceleration += velocity * FRICTION
	velocity += acceleration * delta
	velocity = velocity.clamped(MAX_SPEED)
	position += velocity * delta