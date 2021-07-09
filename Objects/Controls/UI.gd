extends CanvasLayer

var currentScreen = null
onready var world = get_node_or_null("/root/Game")


func _ready():
	# warning-ignore:return_value_discarded
	Networking.connect("connection_created", self, "_on_Networking_connection_created")
	# warning-ignore:return_value_discarded
	Networking.connect("game_started", self, "_on_Networking_game_started")
	# instead of this i should use game_started signal, but it appears 
	# that networking singleton emits signal before initialization of this node
	if Networking.debug: 
		_on_Networking_game_started()
	else:
		show_screen("TitleScreen")


func show_screen(screenName):
	if currentScreen:
		currentScreen.visible = false
	var screenNode = get_node(screenName)
	screenNode.visible = true
	currentScreen = screenNode
	return currentScreen


func _on_Networking_connection_created(_mode):
	show_screen("LobbyScreen").start()


func _on_Networking_game_started():
	show_screen("GameScreen")
	world.get_node("Map").visible = true


func _on_Networking_lost_connection():
	show_screen("TitleScreen")
