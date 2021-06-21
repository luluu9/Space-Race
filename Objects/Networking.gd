extends Node

var SERVER_PORT = 6999
var MAX_PLAYERS = 2

onready var player_scene = preload("res://Objects/PlayerBody.tscn")
onready var world = get_node("/root/Game")

func _ready():
	var my_id = create_connection()
	create_player(my_id)

func create_connection():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	var network = NetworkedMultiplayerENet.new()
	var err = network.create_server(SERVER_PORT, MAX_PLAYERS-1) # -1 to count server as player
	if err:
		network.create_client("127.0.0.1", SERVER_PORT)
	get_tree().network_peer = network
	return network.get_unique_id()


func create_player(peer_id):
	var player_node = player_scene.instance()
	world.add_child(player_node)
	player_node.online(peer_id)


func _player_connected(peer_id):
	print("CONNECTED " + str(peer_id))
	create_player(peer_id)
