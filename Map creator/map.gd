extends StaticBody2D

var STEPS = 100
var WIDTH = 5

func get_bezier_2(step, A, B, C):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 2 ) * A + 2 * t * t_1 * B + pow( t, 2 ) * C

func get_bezier_3(step, A, cA, B, cB):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 3 ) * A + 3 * t * pow( t_1, 2 ) * cA + 3 * pow( t, 2 ) * t_1 * cB + pow( t, 3 ) * B


func draw_bezier_1(A, B):
	draw_line( A, B, Color( 1, 1, 0 ), WIDTH )

func draw_bezier_2(A, B, C):
	var points = []

	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_2( step, A, B, C )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color( 1, 1, 0 ), WIDTH )

func draw_bezier_3(A, cA, cB, B):
	var points = []
	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_3( step, A, cA, B, cB )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color(1, 1, 0), WIDTH )
	
	# create collision shape
	# create_collision_shape(points)


func _draw():
	var beziers = self.get_children()
	for bezier in beziers:
		var points = bezier.get_children()
		if len(points) == 2:
			draw_bezier_1(points[0].position, points[1].position)
		elif len(points) == 3:
			draw_bezier_2(points[0].position, points[1].position, points[2].position)
		elif len(points) == 4:
			draw_bezier_3(points[0].position, points[1].position, points[2].position, points[3].position)