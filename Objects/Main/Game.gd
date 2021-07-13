extends Node


func get_game_screen():
	return get_node("UI/GameScreen")


func get_title_screen():
	return get_node("UI/TitleScreen")


func get_lobby_screen():
	return get_node("UI/LobbyScreen")


func get_map():
	return get_node("Map")


func prepare_start(player_quantity):
	pass


func add_player(player_node):
	add_child(player_node)
