tool # must have for preview in editor
extends StaticBody2D

enum DIR {UP=270, RIGHT=0, DOWN=90, LEFT=180}

var STEPS = 25
var WIDTH = 5
var STARTLINE_MARGIN = 25

onready var startpoint = get_node("startpoint")
onready var start_line = get_node_or_null("start_line")

export (DIR) var start_direction = DIR.UP

func _ready():
	update()
	if not Engine.editor_hint:
		create_collision_shapes()


func get_startpoint():
	return startpoint.position


func get_start_positions(players_amount):
	if not start_line:
		return null
	var start_positions = []
	var rect = start_line.get_texture_rect_real() # Rect2(Vector2(0, 0), Vector2(200, 100))
	print(rect)
	var mid = rect.position + rect.size/2
	if start_direction == DIR.UP or start_direction == DIR.DOWN: 
		# horizontal
		var gap = (rect.size.x-STARTLINE_MARGIN*2)/(players_amount-1)
		var first_pos = Vector2(rect.position.x+STARTLINE_MARGIN, mid.y)
		for i in range(players_amount):
			start_positions.append(first_pos+Vector2(i*gap, 0))
	else: 
		# vertical
		var gap = (rect.size.y-STARTLINE_MARGIN*2)/(players_amount-1)
		var first_pos = Vector2(mid.x, rect.position.y+STARTLINE_MARGIN)
		for i in range(players_amount):
			start_positions.append(first_pos+Vector2(0, i*gap))
	return start_positions


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


func create_collision_shape(points): # https://godotengine.org/qa/23638/why-arent-there-bezier-curves-for-collision-shape-creation
	var col = CollisionShape2D.new()
	var shape = ConcavePolygonShape2D.new()
	var poly_points = PoolVector2Array()
	
	for i in range(0, len(points)-1):
		var new_point = points[i]
		poly_points.append(new_point)
		new_point = points[i+1]
		poly_points.append(new_point)
	
	shape.set_segments(poly_points)
	col.set_shape(shape)
	add_child(col)


func _draw():
	var beziers = self.get_beziers()
	for bezier in beziers:
		var points = bezier.get_points()
		draw_bezier(get_bezier_points(points))


### DEBUG ###
func draw_starting_positions(players_quantity=5):
	var startpoints = get_start_positions(players_quantity)
	if startpoints:
		for point in startpoints:
			var start_sprite = Sprite.new()
			start_sprite.set_texture(preload("res://Objects/Player/ship_icon.png"))
			start_sprite.position = point
			start_sprite.rotation = deg2rad(90+start_direction)
			start_line.add_child(start_sprite)
