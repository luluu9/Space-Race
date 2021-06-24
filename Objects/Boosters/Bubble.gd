extends Area2D

func _on_Bubble_body_entered(body):
	self.hide()
	self.queue_free()
