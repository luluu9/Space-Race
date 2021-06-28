extends Node

var SERVER_PORT = 6996
var MAX_PLAYERS = 4
var HOST_IP = "127.0.0.1"

onready var player_scene = preload("res://Objects/Player/PlayerBody.tscn")
onready var world = get_node_or_null("/root/Game")


func _ready():
	if world: # if null it means that specific scene is running
		var my_id = create_connection()
		create_player(my_id)


func create_connection():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("server_disconnected", self, "host_disconnected")
	var network = NetworkedMultiplayerENet.new()
	var err = network.create_server(SERVER_PORT, MAX_PLAYERS-1) # -1 to count server as player
	if err:
		network.create_client(HOST_IP, SERVER_PORT)
	get_tree().network_peer = network
	return network.get_unique_id()


func create_player(peer_id):
	var player_node = player_scene.instance()
	world.add_child(player_node)
	player_node.online(peer_id)


func player_connected(peer_id):
	print("CONNECTED " + str(peer_id))
	create_player(peer_id)


func player_disconnected(peer_id):
	world.get_node(str(peer_id)).queue_free()


func host_disconnected():
	get_tree().quit()
