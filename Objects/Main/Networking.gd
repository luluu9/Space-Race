extends Node

signal connection_created(mode)
signal info_updated(updated_info)

enum GAME_PHASE {INIT, LOBBY, STARTED}

export (bool) var debug = false

var SERVER_PORT = 6996
var MAX_PLAYERS = 4
var HOST_IP = "127.0.0.1"

onready var player_scene = preload("res://Objects/Player/PlayerBody.tscn")
onready var world = get_node_or_null("/root/Game")

# players_info:
#   - id:
#       - color: blue
#       - nick: john
var players_info = {}
var my_info = {}
var my_peer_id = null
var game_phase = GAME_PHASE.INIT


func _ready():
	if world: # if null it means that specific scene is running
		if debug:
			var my_id = debug_create_connection()
			debug_create_player(my_id)
		else:
			world.get_title_screen().connect("connect", self, "create_connection")
			world.get_title_screen().connect("host", self, "create_connection")


# mode = SERVER/CLIENT
func create_connection(mode, ip=null, port=null):
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	var network = NetworkedMultiplayerENet.new()
	var err = null
	if mode == "SERVER":
		err = network.create_server(SERVER_PORT, MAX_PLAYERS-1)
	else:
		err = network.create_client(ip, port)
	if err:
		push_error("Can't create connection")
		return
	get_tree().network_peer = network
	my_peer_id = network.get_unique_id()
	emit_signal("connection_created", mode)


func _player_connected(peer_id):
	print("Connected: " + str(peer_id))
	rpc_id(peer_id, "update_info", my_peer_id, my_info)


func _player_disconnected(peer_id):
	print("Disconnected: " + str(peer_id))
	players_info.erase(peer_id)


func _server_disconnected():
	get_tree().quit()


# called when player gets new info
remotesync func update_info(peer_id, player_info):
	players_info[peer_id] = player_info
	emit_signal("info_updated", {peer_id: player_info})


func send_info(player_info):
	my_info = player_info
	rpc("update_info", my_peer_id, my_info) 


### DEBUG ###
#   #####   #
#    ###    #
#############
func debug_create_connection():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "debug_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "debug_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "debug_server_disconnected")
	var network = NetworkedMultiplayerENet.new()
	var err = network.create_server(SERVER_PORT, MAX_PLAYERS-1) # -1 to count server as player
	if err:
		network.create_client(HOST_IP, SERVER_PORT)
	get_tree().network_peer = network
	return network.get_unique_id()


func debug_create_player(peer_id):
	var player_node = player_scene.instance()
	world.add_child(player_node)
	player_node.online(peer_id)


func debug_player_connected(peer_id):
	print("CONNECTED " + str(peer_id))
	debug_create_player(peer_id)


func debug_player_disconnected(peer_id):
	world.get_node(str(peer_id)).queue_free()


func debug_server_disconnected():
	get_tree().quit()
