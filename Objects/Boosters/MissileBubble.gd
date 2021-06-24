extends "Bubble.gd"

onready var missile_scene = preload("res://Objects/Boosters/Missile.tscn")

func _on_Bubble_body_entered(body):
	var missile = missile_scene.instance()
	# yield(get_tree().create_timer(1), "timeout")
	missile.start(transform, body)
	get_parent().add_child(missile)
	._on_Bubble_body_entered(body)
