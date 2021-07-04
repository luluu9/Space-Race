extends Control

signal start_game

onready var logs = $HBoxContainer/ConnectionLog
onready var start_button = $HBoxContainer/VBoxContainer/StartButton
onready var color_picker = $HBoxContainer/VBoxContainer/ColorPicker
onready var nickname_edit = $HBoxContainer/VBoxContainer/NicknameEdit
onready var players_node = $HBoxContainer/LobbyPlayers

onready var lobby_font = preload("res://Fonts/LobbyScreen.tres")


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	# warning-ignore:return_value_discarded
	Networking.connect("info_updated", self, "update_info")


func log_message(message):
	logs.add_text(message)
	logs.newline()


func start():
	if get_tree().is_network_server():
		var message = "Hosting, id " + str(get_tree().get_network_unique_id())
		log_message(message)
		start_button.disabled = false
	else:
		var message = "Connecting as peer, id " + str(get_tree().get_network_unique_id())
		log_message(message)


func _player_connected(peer_id):
	var message = "Player connected, id " + str(peer_id)
	log_message(message)


func _player_disconnected(peer_id):
	var message = "Player disconnected, id " + str(peer_id)
	log_message(message)
	remove_player(peer_id)


func _connected_to_server():
	var message = "Connected"
	log_message(message)


func _connected_fail():
	var message = "Connection failed"
	log_message(message)


func _server_disconnected():
	var message = "Server disconnected"
	log_message(message)
	# delete all entries
	for node in players_node.get_children():
		if "color" in node.name or "label" in node.name:
			node.queue_free()


func _on_StartButton_pressed():
	emit_signal("start_game")


func _on_SetButton_pressed():
	var nick = nickname_edit.text
	var color = color_picker.color
	Networking.send_info({"nick": nick, "color": color})


func create_player_nodes(peer_id):
	var player_label = Label.new()
	player_label.name = str(peer_id) + "_label"
	player_label.size_flags_horizontal = SIZE_EXPAND_FILL
	player_label.add_font_override("font", lobby_font)
	
	var player_color = ColorRect.new()
	player_color.name = str(peer_id) + "_color"
	player_color.size_flags_horizontal = SIZE_EXPAND_FILL
	
	players_node.add_child(player_label) 
	players_node.add_child(player_color)
	return [player_label, player_color]


func update_info(player_info):
	for peer_id in player_info:
		var player_label = players_node.get_node_or_null(str(peer_id) + "_label")
		var player_color = players_node.get_node_or_null(str(peer_id) + "_color")
		if not player_label:
			var player_nodes = create_player_nodes(peer_id)
			player_label = player_nodes[0]
			player_color = player_nodes[1]
		for info_key in player_info[peer_id]:
			match info_key:
				"color":
					player_color.color = player_info[peer_id][info_key]
				"nick":
					player_label.text = player_info[peer_id][info_key]


func remove_player(peer_id):
	var player_label = players_node.get_node_or_null(str(peer_id) + "_label")
	if player_label:
		player_label.queue_free()
	var player_color = players_node.get_node_or_null(str(peer_id) + "_color")
	if player_color:
		player_color.queue_free()
