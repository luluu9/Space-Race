extends Control
 
signal connect
signal host


func _on_HostButton_pressed():
	emit_signal("host")


func _on_ConnectButton_pressed():
	emit_signal("connect")
