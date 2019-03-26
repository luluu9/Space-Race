extends StaticBody2D

onready var line = get_node("Line2D")

func _ready():
	var lines = get_tree().get_nodes_in_group("map")
	for line in lines:
		var points = line.get_points()
		var width = line.get_width()/2
	
		for i in range(1, points.size()):
			var poly = CollisionPolygon2D.new()
			var poly_points = PoolVector2Array()
			var angle = points[i-1].angle_to_point(points[i])
	
	
			var new_point = points[i-1] + Vector2(width, width).rotated(angle)
			poly_points.append(new_point)
	
			new_point = points[i] + Vector2(width, width).rotated(angle)
			poly_points.append(new_point)
	
			new_point = points[i] - Vector2(width, width).rotated(angle)
			poly_points.append(new_point)
	
			new_point = points[i-1] - Vector2(width, width).rotated(angle)
			poly_points.append(new_point)
			poly.set_polygon(poly_points)
			add_child(poly)