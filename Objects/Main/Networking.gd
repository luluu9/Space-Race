extends Node

signal connection_created(mode)
signal game_started
signal info_updated(updated_info)

enum GAME_PHASE {INIT, LOBBY, LOADING, STARTED}

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
var players_loading = 0
var players_ready = 0


func _ready():
	if world: # if null it means that specific scene is running
		if debug:
			var my_id = debug_create_connection()
			debug_create_player(my_id)
		else:
			world.get_title_screen().connect("connect", self, "create_connection")
			world.get_title_screen().connect("host", self, "create_connection")
			world.get_lobby_screen().connect("start_game", self, "load_game")


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
	players_info[my_peer_id] = {}
	emit_signal("connection_created", mode)


func _player_connected(peer_id):
	print("Connected: " + str(peer_id))
	rpc_id(peer_id, "update_info", my_peer_id, my_info)
	if get_tree().is_network_server():
		match game_phase:
			GAME_PHASE.LOBBY:
				pass
			GAME_PHASE.STARTED:
				# initialize world to watch only?
				# replicate it
				propagate_replication(peer_id)
				pass


# get nodes that are not persistent and call replicate function on peer
func propagate_replication(peer_id):
	var to_replicate = get_tree().get_nodes_in_group("To_replicate")
	for node in to_replicate:
		rpc_id(peer_id, "replicate", str(node.get_path()), node.filename)
	rpc_id(peer_id, "start_game")


# create node and request info about variables that needs to be replicated
# these variables are stored as strings in 'replication_vars' array 
remote func replicate(node_path, node_resource):
	var node_array = node_path.rsplit("/", true, 1)
	var node_name = node_array[1]
	var node_parent = node_array[0] 
	var node = load(node_resource).instance()
	node.name = node_name
	# if node is e.g. player, input, physics etc. needs to be disabled
	if node.has_method("online"): 
		node.online(int(node_name))
	get_node(node_parent).add_child(node)
	node.rpc_id(1, "request_replication_info", my_peer_id)


func _player_disconnected(peer_id):
	print("Disconnected: " + str(peer_id))
	players_info.erase(peer_id)
	var player_to_delete = world.get_node_or_null(str(peer_id))
	if player_to_delete:
		player_to_delete.queue_free()


func _server_disconnected():
	get_tree().quit()


# called when player gets new info
remotesync func update_info(peer_id, player_info):
	players_info[peer_id] = player_info
	emit_signal("info_updated", {peer_id: player_info})


func send_info(player_info):
	my_info = player_info
	rpc("update_info", my_peer_id, my_info) 


func load_game():
	game_phase = GAME_PHASE.LOADING
	players_loading = len(players_info.keys())
	rpc("prepare_game")


remotesync func player_ready(_peer_id):
	players_ready += 1
	if players_ready == players_loading:
		rpc("start_game")


remotesync func prepare_game():
	get_tree().set_pause(true)
	world.prepare_start(players_info.keys())
	for peer_id in players_info:
		var new_player = player_scene.instance()
		for info_key in players_info[peer_id]:
			match info_key:
				"color":
					new_player.get_node("ship_wings").self_modulate = players_info[peer_id][info_key]
#				"nick":
#					new_player.nick = player_info[peer_id][info_key]
		world.add_player(new_player, peer_id)
		new_player.online(peer_id)
	rpc_id(1, "player_ready", my_peer_id)


remotesync func start_game():
	get_tree().set_pause(false)
	game_phase = GAME_PHASE.STARTED
	emit_signal("game_started")


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


# TODO:
# - allow to replicate variables inside scenes like Timer time in the Banana scene
