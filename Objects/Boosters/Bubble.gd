extends Area2D

func _on_Bubble_body_entered(_body):
	self.hide()
	self.queue_free()
