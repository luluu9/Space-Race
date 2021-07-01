extends Area2D


func _ready():
	randomize()


func _on_Bubble_body_entered(body):
	self.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	give_item(body)
	$Timer.start()


func _on_Timer_timeout():
	self.show()
	$CollisionShape2D.set_deferred("disabled", false)


func give_item(body):
	var item = randi()%(body.Item.size()-1) # -1 because of Item.NONE
	body.set_item(item)
