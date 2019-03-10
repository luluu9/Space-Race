extends Node


func _ready():
	var point = Vector2(-100, 0) 
	print(rad2deg(point.angle()))
	print(point + Vector2(10, 10).rotated(point.angle()))


