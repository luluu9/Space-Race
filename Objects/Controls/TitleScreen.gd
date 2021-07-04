extends Control
 
signal connect(ip, port)
signal host

onready var ip_node = $HBoxContainer/VBoxContainer/IpEdit
onready var port_node = $HBoxContainer/VBoxContainer/PortEdit


func _on_HostButton_pressed():
	emit_signal("host")


func _on_ConnectButton_pressed():
	var ip = ip_node.text
	var port = int(port_node.text)
	if not ip:
		push_warning("IP address not given")
		return
	if not port:
		push_warning("Port not given")
		return
	emit_signal("connect", ip, port)
	
