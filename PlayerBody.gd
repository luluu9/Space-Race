extends KinematicBody2D

var MAX_SPEED = 400
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
	#position += velocity * delta
	var col = move_and_collide(velocity * delta)
	if col:
		var reflect = col.remainder.bounce(col.normal)
		velocity = velocity.bounce(col.normal)*0.1
		move_and_collide(reflect)


func _on_Body_area_entered(area):
	print("ENTERED")
	THRUST = 0
	rotation *= -1
	velocity *= -1 * 1


func _on_Body_area_exited(area):
	print("EXITED")
	THRUST = 600


func _on_Thrust_zone_exited(area):
	MAX_SPEED = 400


func _on_Thrust_zone_entered(body):
	MAX_SPEED = 1000
