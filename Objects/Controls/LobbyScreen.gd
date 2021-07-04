extends Control

signal start_game
signal set_info (info)

onready var logs = $HBoxContainer/ConnectionLog
onready var start_button = $HBoxContainer/VBoxContainer/StartButton
onready var color_picker = $HBoxContainer/VBoxContainer/ColorPicker
onready var nickname_edit = $HBoxContainer/VBoxContainer/NicknameEdit
onready var players_node = $HBoxContainer/LobbyPlayers

onready var lobby_font = preload("res://Fonts/LobbyScreen.tres")

var players_labels = []


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")


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


func _player_connected(id):
	var message = "Player connected, id " + str(id)
	log_message(message)


func _player_disconnected(id):
	var message = "Player disconnected, id " + str(id)
	log_message(message)


func _connected_ok():
	if not nickname_edit.text.empty():
		yield(get_tree().create_timer(1.0), "timeout") # give time to initialize players_info from host
		_on_SetButton_pressed() # if nick selected earlier it will be send
	var message = "Connected"
	log_message(message)


func _connected_fail():
	var message = "Connection failed"
	log_message(message)


func _server_disconnected():
	var message = "Server disconnected"
	log_message(message)
	for peer_id in players_labels.duplicate():
		remove_player(peer_id)


func _on_StartButton_pressed():
	emit_signal("start_game")


func _on_SetButton_pressed():
	var nickname = nickname_edit.text
	var info = ["name", nickname]
	emit_signal("set_info", info)
	var color = color_picker.color
	info = ["color", color]
	emit_signal("set_info", info)


func update_lobby(players_info):
	for peer_id in players_info:
		var player_label = null
		var player_color = null
		for info_name in players_info[peer_id]:
			if not peer_id in players_labels: # player is new, create scenes
				player_label = Label.new()
				player_label.name = peer_id
				player_label.size_flags_horizontal = SIZE_EXPAND_FILL
				player_label.add_font_override("font", lobby_font)
				
				player_color = ColorRect.new()
				player_color.name = peer_id + "_color"
				player_color.size_flags_horizontal = SIZE_EXPAND_FILL
				
				players_node.add_child(player_label) 
				players_node.add_child(player_color)
				
				players_labels.append(peer_id)
			
			player_label = players_node.get_node(peer_id)
			player_color = players_node.get_node(peer_id + "_color")
			var info_value = players_info[peer_id][info_name]
			match info_name:
				"color":
					player_color.color = info_value
				"name":
					player_label.text = info_value 


func remove_player(peer_id):
	if peer_id in players_labels:
		players_node.get_node(peer_id).queue_free()
		players_node.get_node(peer_id + "_color").queue_free()
	players_labels.erase(peer_id)
