extends RigidBody2D

enum Item {NONE=-1, HOMING_MISSILE, BANANA, LASER}

export (int) var engine_thrust = 800 # defines max speed
export (int) var initial_spin_thrust = 10000
export (int) var side_thrust = 500

var thrust = Vector2()
var side_vector = Vector2(1, -2)
var rotation_dir = 0
var spin_thrust = initial_spin_thrust
var color = Color(255, 255, 255) setget set_color

onready var thrust_ray = get_node("RayCast2D")
onready var right_ray = get_node("RayCast2D2")
onready var left_ray = get_node("RayCast2D3")
onready var particles = get_node("Particles")
onready var left_side_particles = get_node("Particles/LeftSideParticles")
onready var right_side_particles = get_node("Particles/RightSideParticles")
onready var camera = get_node("Camera2D")
onready var homing_missile_scene = load("res://Objects/Items/HomingMissile/HomingMissile.tscn")
onready var missile_effect_rect = get_node("MissileEffect/ColorRect")
onready var item_texture_container = get_node("PlayerUI/ItemPanel/ItemContainer")
onready var banana_scene = load("res://Objects/Items/Banana/Banana.tscn")
onready var laser_scene = load("res://Objects/Items/Laser/Laser.tscn")

puppet var remote_transform = Transform2D()
puppet var remote_angular_velocity = 0.0
puppet var remote_linear_velocity = Vector2()
var last_update = 0
var updated = false

var missiles_target = []

var current_item = Item.NONE
var laser_ammo = 0 setget set_laser_ammo

var replication_vars = ["modulate"]


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
	if Input.is_action_just_pressed("USE_ITEM"):
		match current_item:
			Item.HOMING_MISSILE:
				rpc("shoot_missile")
			Item.BANANA:
				rpc("drop_banana")
			Item.LASER:
				rpc("shoot_laser", laser_ammo)
				set_laser_ammo(laser_ammo-1)
				return
		current_item = Item.NONE
		item_texture_container.texture = null


remotesync func shoot_missile():
	var missile = homing_missile_scene.instance()
	missile.start(transform, self)
	get_parent().call_deferred("add_child", missile)


remotesync func drop_banana():
	var banana = banana_scene.instance()
	banana.caller = self
	banana.position = position
	get_parent().add_child(banana)


# we need ammo_id to be sure that each peer has same name of lasers 
# (they can be different if more than one are shooted in same time
remotesync func shoot_laser(ammo_id):
	var laser = laser_scene.instance()
	laser.modulate = color
	laser.start(transform, ammo_id, name)
	get_parent().add_child(laser)


func set_fov():
	var multiplier = get_speed()/engine_thrust - 0.5
	var fov = Vector2(0.5, 0.5)
	if multiplier > 0:
		fov += Vector2(multiplier, multiplier)
	camera.zoom = lerp(camera.zoom, fov, 0.1)


func _process(_delta):
	get_input()


func _integrate_forces(state):
	set_boost()
	if is_network_master():
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
	if thrust_ray.is_colliding() and thrust.x >= 0:
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


# call it after adding to the tree
func online(peer_id):
	self.name = str(peer_id)
	self.set_network_master(peer_id)
	if is_network_master():
		get_node("NetworkTicker").autostart = true
		get_node("Camera2D").current = true
		get_node("NetworkTicker").start()
	else: # physics (e.g. forces) are not used on puppets
		set_physics_process(false)
		set_process(false)
		set_process_input(false)
		get_node("PlayerUI").queue_free()


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


func set_item(item):
	if is_network_master():
		current_item = item
		var texture = null
		match item:
			Item.BANANA:
				texture = load("res://Objects/Items/Banana/Banana.png")
			Item.HOMING_MISSILE:
				texture = load("res://Objects/Items/HomingMissile/Missile.png")
			Item.LASER:
				set_laser_ammo(5)
				return # to prevent changing an item texture to null
		item_texture_container.texture = texture


func immobilize():
	set_use_custom_integrator(true)


func run():
	set_use_custom_integrator(false)


func set_color(_color):
	color = _color
	get_node("ship_wings").self_modulate = color
	


func set_laser_ammo(_laser_ammo):
	if is_network_master():
		laser_ammo = _laser_ammo
		if laser_ammo == 0:
			current_item = Item.NONE
			item_texture_container.texture = null
		else:
			var texture = load("res://Objects/Items/Laser/Laser_ammo_" + str(laser_ammo) + ".png")
			item_texture_container.texture = texture


remote func request_replication_info(peer_id):
	for repl_var in replication_vars:
		rset_id(peer_id, repl_var, get(repl_var))


func _ready():
	for repl_var in replication_vars:
		rset_config(repl_var, MultiplayerAPI.RPC_MODE_REMOTESYNC)


# IDEAS FOR LAG COMPENSATION:
# - measure packet loss/ping to extrapolate how long remote linear velocity should last 
