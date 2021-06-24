extends "RemoteArea2D.gd"

export var speed = 350
export var steer_force = 50.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var ally = null
var target = null


func start(_transform, _ally):
	global_transform = _transform
	velocity = transform.x * speed
	ally = _ally
	position = Vector2(-100, 0)


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
		target = get_closest_player()


func _on_Missile_body_entered(body):
	var players = get_tree().get_nodes_in_group("Players")
	if len(players) > 1 and body == ally:
		return
	explode()


func explode():
	$Particles2D.emitting = false
	set_physics_process(false)
	velocity = Vector2.ZERO
	$AnimationPlayer.play("explode")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
