extends Node2D

var current_map = null
var current_bezier = null

var STEPS = 100
var WIDTH = 5

var SELECTION_DISTANCE = 9

var selection = null
var pressed = false

onready var grid = get_node("Camera2D")

func _input(event):
	var ctrl = Input.is_key_pressed(KEY_CONTROL)
	var create = Input.is_action_just_pressed("MAP_CREATE")
	if ctrl and create:
		if current_map:
			create_bezier()
	elif create:
		current_map = StaticBody2D.new()
		add_child(current_map)
	
	# CHANGE POSITION OF POINT
	if pressed:
		if selection != null:
			selection.set_position(grid.get_snap_point(event.position))
			update()
	
	if event is InputEventMouseButton:
		if event.pressed:
			pressed = true
			if current_bezier:
				selection = get_point_on_cursor(event.position)
				if selection == null and current_bezier.get_child_count() < 4: # max bezier points = 4
					create_point()
		else:
			selection = null
			pressed = false

func create_bezier():
	var name = "bezier_" + str(current_map.get_child_count())
	var bezier = Node2D.new()
	bezier.name = name
	current_map.add_child(bezier)
	current_bezier = bezier

func create_point():
	var name = "point_" + str(current_bezier.get_child_count())
	var point = Node2D.new()
	point.name = name
	point.position = grid.get_snap_point(get_global_mouse_position())
	current_bezier.add_child(point)
	update()

func save_map(map):
	name_map(map)
	pass

# for naming map to save
func name_map(map):
	pass

# POINTS
func get_point_on_cursor(mouse_pos):
	for bezier in current_map.get_children():
		for point in bezier.get_children():
			print(mouse_pos.distance_to(point.position))
			if mouse_pos.distance_to(point.position) < SELECTION_DISTANCE:
				return point
	return null


# BEZIER

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
	
	draw_line( A, B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( B, C, Color( 1, 1, 1, 0.5 ), 1 )

	
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
	
	# draw control lines
	draw_line(  A, cA, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cB,  B, Color( 1, 1, 1, 0.5 ), 1 )
	draw_line( cA, cB, Color( 1, 1, 1, 0.5 ), 1 )

func draw_points(points): #helper
	for point in points:
		draw_circle( point.position, SELECTION_DISTANCE, Color( 1.0, 0.5, 0.5, 0.6 ) )

func _draw():
	if not current_map:
		return
	var beziers = current_map.get_children()
	for bezier in beziers:
		var points = bezier.get_children()
		draw_points(points)
		if len(points) == 2:
			draw_bezier_1(points[0].position, points[1].position)
		elif len(points) == 3:
			draw_bezier_2(points[0].position, points[1].position, points[2].position)
		elif len(points) == 4:
			draw_bezier_3(points[0].position, points[1].position, points[2].position, points[3].position)