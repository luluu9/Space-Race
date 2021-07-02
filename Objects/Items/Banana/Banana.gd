extends Area2D

export var hit_force = 10000
var caller = null # a player who dropped this item


func _ready():
	$Timer.start()


func _on_Banana_body_entered(body):
	if body == caller: # to prevent slip when a caller drops a banana
		caller = null
		return
	body.apply_torque_impulse(hit_force)


func _on_Timer_timeout():
	queue_free()
