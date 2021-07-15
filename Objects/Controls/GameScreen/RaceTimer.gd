extends Control

signal start_race

var texts = ["3...", "2...", "1...", "GO!!!"]
var current_texts = texts.duplicate()
onready var world = get_node("/root/Game")


func _ready():
	# warning-ignore:return_value_discarded
	Networking.connect("game_started", self, "start")


# immobilize the player and start count down
func start():
	if not Networking.debug:
		var player = world.get_map().get_node(str(Networking.my_peer_id))
		player.immobilize()
		# warning-ignore:return_value_discarded
		connect("start_race", player, "run")
		self.visible = true
		next_text()
		$Timer.start()


# on each timeout change text
func _on_Timer_timeout():
	next_text()


# change text and tween alpha.
# if every text is used, change properties to original in case of a game reset
func next_text():
	var new_text = current_texts.pop_front()
	if new_text:
		$Tween.stop_all() # to prevent disappearing if tween and timer times are not synchronized
		$Label.text = new_text
		if len(current_texts) != 0:
			$Tween.interpolate_property($Label, "self_modulate:a", 1, 0, $Timer.wait_time, $Tween.TRANS_CUBIC)
			$Tween.start()
		else:
			$Label.self_modulate.a = 1
			emit_signal("start_race")
	else:
		$Timer.stop()
		$Tween.stop_all()
		current_texts = texts.duplicate()
		self.visible = false
	
