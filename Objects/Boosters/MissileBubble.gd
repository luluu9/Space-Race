extends "Bubble.gd"

onready var missile_scene = load("res://Objects/Boosters/Missile.tscn")

func _on_Bubble_body_entered(body):
	var missile = missile_scene.instance()
	missile.set_network_master(1)
	# call_deferred due to some ugly error
	missile.start(transform, body)
	get_parent().call_deferred("add_child", missile)
	._on_Bubble_body_entered(body)
