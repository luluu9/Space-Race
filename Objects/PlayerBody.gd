extends RigidBody2D

export (int) var engine_thrust = 800 # defines max speed
export (int) var initial_spin_thrust = 6000
export (int) var side_thrust = 500

var thrust = Vector2()
var side_vector = Vector2(1, -2)
var rotation_dir = 0
var spin_thrust = initial_spin_thrust

onready var thrust_ray = get_node("RayCast2D")
onready var right_ray = get_node("RayCast2D2")
onready var left_ray = get_node("RayCast2D3")
onready var engine_particles = get_node("EngineParticles")


func get_input():
	thrust = Vector2()
	if Input.is_action_pressed("ACCELERATE"):
		thrust = Vector2(engine_thrust, 0)
		engine_particles.emitting = true
	else:
		engine_particles.emitting = false
	if Input.is_action_pressed("REVERSE"):
		thrust = Vector2(-0.4*engine_thrust, 0)
	rotation_dir = 0
	if Input.is_action_pressed("RIGHT"):
		rotation_dir += 1
	if Input.is_action_pressed("LEFT"):
		rotation_dir -= 1


func _process(_delta):
	get_input()


func _physics_process(_delta):
	if thrust_ray.is_colliding():
		var col_point = thrust_ray.get_collision_point()
		var distance = position.distance_to(col_point)
		thrust.x += 50*engine_thrust/distance
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_dir * spin_thrust)
	set_spin_thrust()
	set_side_thrust()


func set_spin_thrust():
	if linear_velocity.length() > engine_thrust/2:
		spin_thrust = initial_spin_thrust * linear_velocity.length()*2/engine_thrust


func set_side_thrust():
	if left_ray.is_colliding():
		var left_vector = Vector2(side_vector.x, side_vector.y*-1)
		var force = (left_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, -10).rotated(rotation) * linear_velocity.length()/500
		add_force(offset, force)
	if right_ray.is_colliding():
		var right_vector = side_vector
		var force = (right_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, 10).rotated(rotation) * linear_velocity.length()/500
		add_force(offset, force)
