extends "Bubble.gd"

onready var missile_scene = load("res://Objects/Boosters/Missile.tscn")

func _on_Bubble_body_entered(body):
	self.visible = false
	var missile = missile_scene.instance()
	missile.set_network_master(1)
	# call_deferred due to some ugly error
	missile.start(transform, body)
	var players = get_tree().get_nodes_in_group("Players")
	if len(players) == 1:
		yield(get_tree().create_timer(0.5), "timeout")
	get_parent().call_deferred("add_child", missile)
	._on_Bubble_body_entered(body)
