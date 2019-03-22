# https://github.com/JohnMeadow1/GodotGeometryElements/tree/master/godot_3/final/bezier_curve
tool
extends Node2D

var selectionDistance = 10
var pressed           = false
var selection         = null

var points = []
var STEPS  = 100
var WIDTH = 5

func _ready():
	update()


func _input(event):
	print("nowtf")
	if event is InputEventMouseMotion:
		if pressed:
			if selection != null:
				selection.set_position(event.position)
		else:
			selection = null
			for point in get_children():
				if event.position.distance_to(point.position) < selectionDistance:
					selection = point
	if event is InputEventMouseButton:
		if event.pressed:
			pressed = true
			selection = null
			for point in get_children():
				if event.position.distance_to(point.position) < selectionDistance:
					selection = point
		else:
			pressed   = false
			selection = null

func _draw():
	draw_nodes()
	draw_bezier_1()
	draw_bezier_2()
	draw_bezier_3()

	if selection != null:  # draw selected point
		draw_circle( selection.position, 20, Color( 1, 1, 1, 0.3 ) )

func get_bezier_1(step, A, B ):
	var t = float(step) / STEPS
	return (1 - t) * A + t * B

func get_bezier_2(step, A, B, C):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 2 ) * A + 2 * t * t_1 * B + pow( t, 2 ) * C

func get_bezier_3(step, A, cA, B, cB):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	return pow( t_1, 3 ) * A + 3 * t * pow( t_1, 2 ) * cA + 3 * pow( t, 2 ) * t_1 * cB + pow( t, 3 ) * B

func get_bezier_4(step, A, cA, cB, B):
	var t = float(step) / STEPS
	var t_1 = 1 - t
	print( 3 * pow( t, 2 ) * t_1 )
	return pow( t_1, 3 ) * A + 3 * t * pow( t_1, 2 ) * cA + 3 * pow( t, 2 ) * t_1 * cB + pow( t, 3 ) * B

func draw_bezier_1():
	var A  = get_child(0).position
	var B  = get_child(1).position

	draw_line( A, B, Color( 1, 1, 0 ), WIDTH )
	#draw_circle( get_bezier_1( show_t, A, B ), 5, Color( 0, 1, 0  ) )

func draw_bezier_2():
	var A = get_child(2).position
	var B = get_child(3).position
	var C = get_child(4).position
	points = []

	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_2( step, A, B, C )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color( 1, 1, 0 ), WIDTH )
	#draw_circle( get_bezier_2( show_t, A, B, C ), 5, Color( 0, 1, 0 ) )
	
	draw_line( A, B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( B, C, Color( 1, 1, 1, 0.5 ), 1 )

	
func draw_bezier_3():
	var A  = get_child(5).position
	var cA = get_child(6).position
	var cB = get_child(7).position
	var B  = get_child(8).position

	points = []
	var point = Vector2()
	for step in range( STEPS + 1 ):
		point = get_bezier_3( step, A, cA, B, cB )
		points.push_back( point )

	for p in range( STEPS ):
		draw_line( points[p], points[p+1], Color(1, 1, 0), WIDTH )
	
	# create collision shape
	create_collision_shape(points)
	
	# draw control lines
	draw_line(  A, cA, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cB,  B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cA, cB, Color( 1, 1, 1, 0.5 ), 1 )
	

func draw_nodes():
	for point in get_children():
		draw_circle( point.position, 7, Color( 1.0, 0.5, 0.5 ) )

func create_collision_shape(points):
	pass
#		var pol_width = WIDTH/2
#		for i in range(1, points.size()):
#			var poly = CollisionPolygon2D.new()
#			var poly_points = PoolVector2Array()
#			var angle = points[i-1].angle_to_point(points[i])
#			#print(angle)
#
#			var new_point = points[i-1] + Vector2(pol_width, pol_width).rotated(angle)
#			poly_points.append(new_point)
#
#			new_point = points[i] + Vector2(pol_width, pol_width).rotated(angle)
#			poly_points.append(new_point)
#
#			new_point = points[i] - Vector2(pol_width, pol_width).rotated(angle)
#			poly_points.append(new_point)
#
#			new_point = points[i-1] - Vector2(pol_width, pol_width).rotated(angle)
#			poly_points.append(new_point)
#			poly.set_polygon(poly_points)
#			add_child(poly)