extends RigidBody2D

export (int) var engine_thrust = 800 # defines max speed
export (int) var spin_thrust = 5000

var thrust = Vector2()
var rotation_dir = 0

onready var thrust_ray = get_node("RayCast2D")

func get_input():
	if Input.is_action_pressed("ACCELERATE"):
		thrust = Vector2(engine_thrust, 0)
	else:
		thrust = Vector2()
	rotation_dir = 0
	if Input.is_action_pressed("RIGHT"):
		rotation_dir += 1
	if Input.is_action_pressed("LEFT"):
		rotation_dir -= 1


func _process(delta):
	get_input()


func _physics_process(delta):
	if thrust_ray.is_colliding():
		var col_point = thrust_ray.get_collision_point()
		var distance = position.distance_to(col_point)
		thrust.x += 50*engine_thrust/distance
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_dir * spin_thrust)
#	print(linear_velocity.length())
#	print(linear_velocity.length()/max_speed)
#	if not thrust_ray.is_colliding():
#		add_central_force(-linear_velocity*linear_velocity.length()/max_speed)
#		#set_linear_damp(linear_velocity.length()/max_speed)
