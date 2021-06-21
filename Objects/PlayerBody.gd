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
onready var left_side_particles = get_node("LeftSideParticles")
onready var right_side_particles = get_node("RightSideParticles")

# puppet var r_linear_velocity = Vector2(0, 0) setget update_linear_velocity


func get_input():
	thrust = Vector2()
	if Input.is_action_pressed("ACCELERATE"):
		thrust = Vector2(engine_thrust, 0)
		engine_particles.emit("accel")
	else:
		engine_particles.stop_emit("accel")
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
	set_boost()
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_dir * spin_thrust)
	set_spin_thrust()
	set_side_thrust()


func set_boost():
	if thrust_ray.is_colliding():
		var col_point = thrust_ray.get_collision_point()
		var distance = position.distance_to(col_point)
		thrust.x += 50*engine_thrust/distance
		engine_particles.emit("boost")
		# engine_particles.lifetime = 0.4*distance/75
	else:
		engine_particles.stop_emit("boost")


func set_spin_thrust():
	if linear_velocity.length() > engine_thrust/2:
		spin_thrust = initial_spin_thrust * linear_velocity.length()*2/engine_thrust


func set_side_thrust():
	if left_ray.is_colliding():
		var left_vector = Vector2(side_vector.x, side_vector.y*-1)
		var force = (left_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, -10).rotated(rotation) * linear_velocity.length()/500
		left_side_particles.emitting = true
		add_force(offset, force)
	if right_ray.is_colliding():
		var right_vector = side_vector
		var force = (right_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, 10).rotated(rotation) * linear_velocity.length()/500
		right_side_particles.emitting = true
		add_force(offset, force)


func online(peer_id):
	self.name = str(peer_id)
	self.set_network_master(peer_id)
	if is_network_master():
		get_node("NetworkTicker").autostart = true
		self.get_node("Camera2D").current = true
	else: # physics (e.g. forces) are not used on puppets
		set_physics_process(false)
		set_process(false)


func _on_NetworkTicker_timeout():
	rpc_unreliable("update_values", position, rotation)


remote func update_values(lin_vel, pos, rot, app_for):
	position = pos
	rotation = rot
