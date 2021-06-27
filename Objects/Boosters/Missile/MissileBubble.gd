extends "../Bubble.gd"

onready var missile_scene = load("res://Objects/Boosters/Missile/Missile.tscn")

func _on_Bubble_body_entered(body):
	if get_tree().is_network_server():
		rpc("add_missile", body.name)


remotesync func add_missile(body_name):
	self.visible = false
	var body = get_node("/root/Game/" + body_name)
	if body:
		var missile = missile_scene.instance()
		missile.start(body.transform, body)
		var players = get_tree().get_nodes_in_group("Players")
		if len(players) == 1: # if player is solo give time for escape
			yield(get_tree().create_timer(0.5), "timeout")
		# call_deferred due to some ugly error
		get_parent().call_deferred("add_child", missile)
	._on_Bubble_body_entered(body)
