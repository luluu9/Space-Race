extends "../RemoteArea2D.gd"

export var speed = 450
export var steer_force = 70.0
export var hit_force = 1000

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var ally = null
var target = null
var exploded = false
var protect_ally = true

onready var world = get_node("/root/Game")


func _ready():
	set_network_master(1)


func start(_transform, _ally):
	global_transform = _transform
	velocity = transform.x * speed
	ally = _ally
	name = ally.name + "_missile"


func _enter_tree():
	$Particles2D.emitting = true


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
			new_target.rpc_id(target_peer_id, "set_missile_target_effect", self.name, true)
			if target: # target could be null (on first time call)
				var old_target_peer_id = int(target.name)
				target.rpc_id(old_target_peer_id, "set_missile_target_effect", self.name, false)
		target = new_target


func _on_Missile_body_entered(body):
	if is_network_master():
		var players = get_tree().get_nodes_in_group("Players")
		# prevent exploding on a caller body for the first seconds
		if len(players) > 1 and body == ally and protect_ally: 
			return
		if not exploded:
			rpc("explode", int(body.name), position)
			exploded = true


remotesync func explode(body_peer_id, _position=null):
	if is_instance_valid(self): # check if not freed already
		if _position: # synchronize position
			position = _position
		$Particles2D.emitting = false
		set_physics_process(false)
		set_process(false)
		velocity = Vector2.ZERO
		if target:
			var target_peer_id = int(target.name)
			target.rpc_id(target_peer_id, "set_missile_target_effect", self.name, false)
		$AnimationPlayer.play("explode")
		# apply an impulse only on the affected player (position is synchronized)
		if get_tree().get_network_unique_id() == body_peer_id:
			var body = world.get_map().get_node(str(body_peer_id))
			var offset = body.position - self.position
			body.apply_impulse(offset, Vector2(hit_force, 0).rotated(rotation))
		yield($AnimationPlayer, "animation_finished")
		queue_free()


func _on_ProctectTimer_timeout():
	protect_ally = false
