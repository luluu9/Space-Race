extends Area2D

export var hit_force = 10000

func _ready():
	$Timer.start()

func _on_Banana_body_entered(body):
	body.apply_torque_impulse(hit_force)


func _on_Timer_timeout():
	queue_free()
