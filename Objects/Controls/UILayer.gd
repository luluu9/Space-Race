extends CanvasLayer

var currentScreen = null

onready var screensNode = $Screens


func _ready():
	show_screen("TitleScreen")


func show_screen(screenName):
	if currentScreen:
		currentScreen.visible = false
	
	var screenNode = screensNode.get_node(screenName)
	screenNode.visible = true
	currentScreen = screenNode


func _on_TitleScreen_host():
	show_screen("LobbyScreen")


func _on_TitleScreen_connect():
	show_screen("ConnectScreen")


func _on_Networking_connected():
	show_screen("LobbyScreen")


func _on_LobbyScreen_start_game():
	show_screen("GameScreen")


func _on_Networking_started():
	show_screen("GameScreen")


func _on_Networking_lost_connection():
	show_screen("TitleScreen")
