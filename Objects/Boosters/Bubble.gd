extends Area2D

func _on_Bubble_body_entered(_body):
	self.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Timer.start()


func _on_Timer_timeout():
	self.show()
	$CollisionShape2D.set_deferred("disabled", false)
