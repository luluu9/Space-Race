extends Area2D

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


func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer


func get_closest_player():
	var players = get_tree().get_nodes_in_group("Players")
	var closest = players[0]
	var closest_distance = (players[0].position - self.position).length()
	for i in range(1, len(players)):
		if len(players) > 1 and players[i] == ally:
			continue
		var distance = (players[i].position - self.position).length()
		if distance < closest_distance:
			closest = players[i]
			closest_distance = distance
	return closest
		 
	

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	position += velocity * delta


func _process(_delta):
	target = get_closest_player()


func _on_Missile_body_entered(body):
	var players = get_tree().get_nodes_in_group("Players")
	if len(players) > 1 and body == ally:
		return
	explode()


func explode():
	queue_free()
