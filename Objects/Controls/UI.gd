extends CanvasLayer

var currentScreen = null


func _ready():
	# warning-ignore:return_value_discarded
	Networking.connect("connection_created", self, "_on_Networking_connection_created")

	show_screen("TitleScreen")


func show_screen(screenName):
	if currentScreen:
		currentScreen.visible = false
	var screenNode = get_node(screenName)
	screenNode.visible = true
	currentScreen = screenNode


func _on_Networking_connection_created(mode):
	show_screen("LobbyScreen")


func _on_Networking_started():
	show_screen("GameScreen")


func _on_Networking_lost_connection():
	show_screen("TitleScreen")
