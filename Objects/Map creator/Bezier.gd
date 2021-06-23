tool # must have for preview in editor
extends Node2D

func get_points():
	var points = []
	for node in get_children():
		if node.name.begins_with("point"):
			points.append(node.position)
	return points
	
