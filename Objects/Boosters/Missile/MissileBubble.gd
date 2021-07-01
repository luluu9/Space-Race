extends "../Bubble.gd"

onready var missile_scene = load("res://Objects/Boosters/Missile/Missile.tscn")

func _on_Bubble_body_entered(body):
	if get_tree().is_network_server():
		rpc("give_missile", body.name)


remotesync func give_missile(body_name):
	self.visible = false
	var body = get_node("/root/Game/" + body_name)
	if body:
		body.set_item(body.Item.HOMING_MISSILE)
	._on_Bubble_body_entered(body)
