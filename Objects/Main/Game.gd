extends Node

export (PackedScene) var map_scene = preload("res://Objects/Maps/Map.tscn") 

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
	return get_node_or_null("Map")


func prepare_start(_players_ids):
	if get_map(): # delete previous map if exists
		get_map().free()
	var map = map_scene.instance()
	map.name = "Map"
	add_child(map)
	players_ids = _players_ids
	players_ids.sort()
	start_positions = get_map().get_start_positions(len(players_ids))
	# if map hasn't got a start line, use the start point
	if not start_positions:
		start_positions = []
		for _i in range(len(players_ids)):
			start_positions.append(get_map().get_startpoint())
	else:
		start_line_position = get_map().start_line.position


func add_player(player_node, peer_id):
	if get_node_or_null(str(peer_id)):
		get_node_or_null(str(peer_id)).free()
	var id_position = players_ids.find(peer_id)
	player_node.position = start_line_position + start_positions[id_position]
	get_map().add_child(player_node)
