extends "../RemoteArea2D.gd"

var speed = 1000
var hit_force = 100
var ally_name = "0" # not any peer can have 0 as peer id so it's OK to initialize

var velocity = Vector2()


func start(_transform, ammo_id, peer_id_str):
	set_network_master(1)
	transform = _transform
	ally_name = peer_id_str
	name = ally_name + "_laser" + str(ammo_id)
	velocity = Vector2(speed, 0).rotated(rotation)


func _physics_process(delta):
	if is_network_master():
		position += velocity * delta
		rset_unreliable("remote_transform", transform)
		rset_unreliable("remote_velocity", velocity)
	else:
		extrapolate_velocity(delta)


# destroy laser when enters on body and affect player
func _on_Laser_body_entered(body):
	if body.name == "Map":
		queue_free()
	elif body.name != ally_name:
		var offset = body.position - self.position
		body.apply_impulse(offset, Vector2(hit_force, 0).rotated(rotation))
		queue_free()


# destroy laser after some time if it wasn't destroyed by wall
func _on_Timer_timeout():
	queue_free()
