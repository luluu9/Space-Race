extends StaticBody2D

var STEPS = 100
var WIDTH = 5

onready var startpoint = get_node("startpoint")

func _ready():
	create_collision_shapes()

func get_startpoint():
	return startpoint.position

func create_collision_shapes():
	for bezier in get_beziers():
		var points = bezier.get_points()
		create_collision_shape(get_bezier_points(points))

func get_beziers():
	var beziers = []
	for node in get_children():
		if node.name.begins_with("bezier"):
			beziers.append(node)
	return beziers

func get_bezier_points(points):
	var bezier_points = []
	if len(points) == 2:
		return points
	elif len(points) == 3:
		for step in range( STEPS + 1 ):
			var point = get_bezier_2(step, points[0], points[1], points[2])
			bezier_points.push_back( point )
	elif len(points) == 4:
		for step in range( STEPS + 1 ):
			var point = get_bezier_3(step, points[0], points[1], points[3], points[2])
			bezier_points.push_back( point )
	return bezier_points

func get_bezier_2(step, A, B, C):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 2 ) * A + 2 * t * t_1 * B + pow( t, 2 ) * C

func get_bezier_3(step, A, cA, B, cB):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 3 ) * A + 3 * t * pow( t_1, 2 ) * cA + 3 * pow( t, 2 ) * t_1 * cB + pow( t, 3 ) * B

func draw_bezier(bezier_points):
	if len(bezier_points) < 2:
		return
	elif len(bezier_points) == 2:
		draw_line(bezier_points[0], bezier_points[1], Color( 1, 1, 0 ), WIDTH )
	else:
		for p in range(STEPS):
			draw_line(bezier_points[p], bezier_points[p+1], Color( 1, 1, 0 ), WIDTH )


func create_collision_shape(points):
	var pol_width = WIDTH/2
	for i in range(1, points.size()):
		var poly = CollisionPolygon2D.new()
		var poly_points = PoolVector2Array()
		var angle = points[i-1].angle_to_point(points[i])

		var new_point = points[i-1] + Vector2(pol_width, pol_width).rotated(angle)
		poly_points.append(new_point)

		new_point = points[i] + Vector2(pol_width, pol_width).rotated(angle)
		poly_points.append(new_point)

		new_point = points[i] - Vector2(pol_width, pol_width).rotated(angle)
		poly_points.append(new_point)

		new_point = points[i-1] - Vector2(pol_width, pol_width).rotated(angle)
		poly_points.append(new_point)
		poly.set_polygon(poly_points)
		add_child(poly)

func _draw():
	var beziers = self.get_beziers()
	for bezier in beziers:
		var points = bezier.get_points()
		draw_bezier(get_bezier_points(points))