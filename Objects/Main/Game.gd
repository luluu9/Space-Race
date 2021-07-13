extends Node

var start_positions = []
var players_ids = []
var start_line_position = Vector2()

func get_game_screen():
	return get_node("UI/GameScreen")


func get_title_screen():
	return get_node("UI/TitleScreen")


func get_lobby_screen():
	return get_node("UI/LobbyScreen")


func get_map():
	return get_node("Map")


func prepare_start(_players_ids):
	players_ids = _players_ids
	players_ids.sort()
	start_positions = get_map().get_start_positions(len(players_ids))
	# if map hasn't got a start line, use the start point
	if not start_positions:
		start_positions = []
		for i in range(len(players_ids)):
			start_positions.append(get_map().get_startpoint())
	else:
		start_line_position = get_map().start_line.position


func add_player(player_node, peer_id):
	var id_position = players_ids.find(peer_id)
	player_node.position = start_line_position + start_positions[id_position]
	add_child(player_node)
