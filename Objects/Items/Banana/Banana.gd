extends Area2D

export var hit_force = 10000
var caller = null # a player who dropped this item

var replication_vars = ["global_position"]


func _ready():
	for repl_var in replication_vars:
		rset_config(repl_var, MultiplayerAPI.RPC_MODE_REMOTESYNC)
	$Timer.start()


func _on_Banana_body_entered(body):
	if body == caller: # to prevent slip when a caller drops a banana
		caller = null
		return
	body.apply_torque_impulse(hit_force)


func _on_Timer_timeout():
	queue_free()


remote func request_replication_info(peer_id):
	for repl_var in replication_vars:
		rset_id(peer_id, repl_var, get(repl_var))
