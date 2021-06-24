extends "../RemoteArea2D.gd"

export var speed = 450
export var steer_force = 70.0
export var hit_force = 1000

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var ally = null
var target = null


func start(_transform, _ally):
	global_transform = _transform
	velocity = transform.x * speed
	ally = _ally


func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer


func get_closest_player():
	var players = get_tree().get_nodes_in_group("Players")
	var closest = null
	var closest_distance = null
	for i in range(0, len(players)):
		if len(players) > 1 and players[i] == ally:
			continue
		var distance = (players[i].position - self.position).length()
		if closest == null or distance < closest_distance:
			closest = players[i]
			closest_distance = distance
	return closest


func _physics_process(delta):
	if is_network_master():
		acceleration += seek()
		velocity += acceleration * delta
		velocity = velocity.clamped(speed)
		rotation = velocity.angle()
		position += velocity * delta
		rset_unreliable("remote_transform", transform)
		rset_unreliable("remote_velocity", velocity)
	else:
		extrapolate_velocity(delta)


func _process(_delta):
	if is_network_master():
		var new_target = get_closest_player()
		if target != new_target: # seriously new target
			var target_peer_id = int(new_target.name)
			get_node("/root/Game").get_game_screen().rpc_id(target_peer_id, "set_missile_target_effect", true)
			if target: # target could be null (on first time call)
				var old_target_peer_id = int(target.name)
				get_node("/root/Game").get_game_screen().rpc_id(old_target_peer_id, "set_missile_target_effect", false)
		target = new_target
			


func _on_Missile_body_entered(body):
	var players = get_tree().get_nodes_in_group("Players")
	if len(players) > 1 and body == ally:
		return
	var offset = body.position - self.position
	body.apply_impulse(offset, Vector2(hit_force, 0).rotated(rotation))
	explode()


func explode():
	if is_network_master():
		var old_target_peer_id = int(target.name)
		get_node("/root/Game").get_game_screen().rpc_id(old_target_peer_id, "set_missile_target_effect", false)
	$Particles2D.emitting = false
	set_physics_process(false)
	velocity = Vector2.ZERO
	$AnimationPlayer.play("explode")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
