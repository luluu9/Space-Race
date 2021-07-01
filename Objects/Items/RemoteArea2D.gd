extends Area2D

export (int) var network_tick = 1/60
var network_tween = null

puppet var remote_transform = Vector2() setget remote_transform_set
puppet var remote_velocity = Vector2()


func _ready():
	network_tween = Tween.new()
	add_child(network_tween)


func extrapolate_velocity(delta):
	if not network_tween.is_active():
		rotation = remote_velocity.angle()
		position += remote_velocity * delta


func remote_transform_set(_transform):
	remote_transform = _transform
	network_tween.interpolate_property(self, "transform", transform, remote_transform, network_tick)
	network_tween.start()

