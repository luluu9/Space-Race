extends RigidBody2D

export (int) var engine_thrust = 800 # defines max speed
export (int) var initial_spin_thrust = 10000
export (int) var side_thrust = 500

var thrust = Vector2()
var side_vector = Vector2(1, -2)
var rotation_dir = 0
var spin_thrust = initial_spin_thrust

onready var thrust_ray = get_node("RayCast2D")
onready var right_ray = get_node("RayCast2D2")
onready var left_ray = get_node("RayCast2D3")
onready var particles = get_node("Particles")
onready var left_side_particles = get_node("Particles/LeftSideParticles")
onready var right_side_particles = get_node("Particles/RightSideParticles")
onready var camera = get_node("Camera2D")
onready var missile_scene = load("res://Objects/Boosters/Missile/Missile.tscn")
onready var missile_effect_rect = get_node("MissileEffect/ColorRect")

puppet var remote_transform = Transform2D()
puppet var remote_angular_velocity = 0.0
puppet var remote_linear_velocity = Vector2()
var last_update = 0
var updated = false

var missiles_target = []


func get_input():
	thrust = Vector2()
	if Input.is_action_pressed("ACCELERATE"):
		thrust = Vector2(engine_thrust, 0)
		particles.rpc("emit_engine", "accel")
	else:
		particles.rpc("stop_emit_engine", "accel")
	if Input.is_action_pressed("REVERSE"):
		thrust = Vector2(-0.4*engine_thrust, 0)
	rotation_dir = 0
	if Input.is_action_pressed("RIGHT"):
		rotation_dir += 1
	if Input.is_action_pressed("LEFT"):
		rotation_dir -= 1


func _input(_event):
	if Input.is_action_just_pressed("SHOOT"):
		rpc("shoot", name)


remotesync func shoot(name):
	var missile = missile_scene.instance()
	var body = get_parent().get_node(name)
	missile.start(body.transform, body)
	get_parent().call_deferred("add_child", missile)


func set_fov():
	var multiplier = get_speed()/engine_thrust - 0.5
	var fov = Vector2(1, 1)
	if multiplier > 0:
		fov += Vector2(multiplier, multiplier)
	camera.zoom = lerp(camera.zoom, fov, 0.1)


func _process(_delta):
	get_input()


func _integrate_forces(state):
	set_boost()
	if self.is_network_master():
		set_applied_force(thrust.rotated(rotation))
		set_applied_torque(rotation_dir * spin_thrust)
		# set_spin_thrust()
		set_side_thrust()
	else:
		if not updated:
			var interpolated_transform = state.transform.interpolate_with(remote_transform, 0.5)
			state.set_transform(interpolated_transform)
			updated = true
		state.set_linear_velocity(remote_linear_velocity)
		state.set_angular_velocity(remote_angular_velocity)
	set_fov()


func set_boost():
	if thrust_ray.is_colliding():
		var col_point = thrust_ray.get_collision_point()
		var distance = position.distance_to(col_point)
		thrust.x += 50*engine_thrust/distance
		particles.rpc("emit_engine", "boost")
	else:
		particles.rpc("stop_emit_engine", "boost")


func set_spin_thrust():
	if linear_velocity.length() > engine_thrust/2:
		spin_thrust = initial_spin_thrust * get_speed()*2/engine_thrust


func set_side_thrust():
	if left_ray.is_colliding():
		var left_vector = Vector2(side_vector.x, side_vector.y*-1)
		var force = (left_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, -10).rotated(rotation) * get_speed()/500
		particles.rpc_unreliable("emit_side", "left")
		add_force(offset, force)
	if right_ray.is_colliding():
		var right_vector = side_vector
		var force = (right_vector*side_thrust).rotated(rotation)
		var offset = Vector2(0, 10).rotated(rotation) * get_speed()/500
		particles.rpc_unreliable("emit_side", "right")
		add_force(offset, force)


func online(peer_id):
	self.name = str(peer_id)
	self.set_network_master(peer_id)
	if is_network_master():
		get_node("NetworkTicker").autostart = true
		get_node("Camera2D").current = true
	else: # physics (e.g. forces) are not used on puppets
		set_physics_process(false)
		set_process(false)
		set_process_input(false)


func _on_NetworkTicker_timeout():
	var data = {
		"time": OS.get_system_time_msecs(),
		"remote_transform": transform,
		"remote_linear_velocity": linear_velocity,
		"remote_angular_velocity": angular_velocity
		}
	rpc_unreliable("remote_update", data)


remote func remote_update(data):
	if last_update < data["time"]:
		remote_transform = data["remote_transform"]
		remote_linear_velocity = data["remote_linear_velocity"]
		remote_angular_velocity = data["remote_angular_velocity"]
		last_update = data["time"]
		updated = false


func get_speed():
	return linear_velocity.length()


remotesync func set_missile_target_effect(missile_name, value):
	if value == true:
		if not missile_name in missiles_target:
			missiles_target.append(missile_name)
		if len(missile_name) > 0:
			missile_effect_rect.visible = true
	else:
		if missile_name in missiles_target:
			missiles_target.erase(missile_name)
		if len(missiles_target) == 0:
			missile_effect_rect.visible = false


# IDEAS FOR LAG COMPENSATION:
# - measure packet loss/ping to extrapolate how long remote linear velocity should last 
