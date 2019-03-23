extends Camera2D

var GAP = 50
var SPEED = 15

var SNAP_MARGIN = 5 # on one side, totally SNAP_MARGIN * 2

var VECTOR_ZOOM = Vector2(0.5, 0.5)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_W:
				position.y -= SPEED
			if event.scancode == KEY_S:
				position.y += SPEED
			if event.scancode == KEY_A:
				position.x -= SPEED
			if event.scancode == KEY_D:
				position.x += SPEED
			update()

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom /= VECTOR_ZOOM
				update()
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom *= VECTOR_ZOOM
				update()

func draw_grid():
	var res = get_viewport_rect().size
	res.x *= zoom.x
	res.y *= zoom.y

	var move_x = GAP - fposmod(position.x, GAP )
	for i in range(0, ceil(res.x / GAP / zoom.x)): # VERTICAL
		var pos_x =  (i * GAP  + move_x) * zoom.x
		draw_line(Vector2(pos_x, 0), Vector2(pos_x, res.y), Color(0.4, 0.4, 0.4, 0.8), 1)
	
	var move_y = GAP - fposmod(position.y, GAP )
	for i in range(0, ceil(res.y / GAP / zoom.y)): # HORIZONTAL
		var pos_y =  (i * GAP + move_y) * zoom.y
		draw_line(Vector2(0, pos_y), Vector2(res.x, pos_y), Color(0.4, 0.4, 0.4, 0.8), 1)

func get_snap_point(point):
	var res = get_viewport_rect().size
	res.x *= zoom.x
	res.y *= zoom.y
	
	var snap_point = point
	
	var move_x = GAP - fposmod(position.x, GAP)
	for i in range(0, ceil(res.x / GAP / zoom.x)): 
		var pos_x =  (i * GAP + move_x) * zoom.x + position.x
		if abs(pos_x - point.x) <= SNAP_MARGIN:
			snap_point.x = pos_x
			break

	var move_y = GAP - fposmod(position.y, GAP)
	for i in range(0, ceil(res.y / GAP / zoom.y)):
		var pos_y =  (i * GAP + move_y) * zoom.y + position.y
		if abs(pos_y - point.y) <= SNAP_MARGIN:
			snap_point.y = pos_y
			break
	return snap_point


func _draw():
	draw_grid()