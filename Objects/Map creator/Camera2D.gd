extends Camera2D

var GAP = 50
var SPEED = 15

var SNAP_MARGIN = 5 # on one side, totally SNAP_MARGIN * 2

var VECTOR_ZOOM = Vector2(0.5, 0.5)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			var CURR_SPEED = SPEED * zoom.x
			if event.scancode == KEY_W:
				position.y -= CURR_SPEED
			if event.scancode == KEY_S:
				position.y += CURR_SPEED
			if event.scancode == KEY_A:
				position.x -= CURR_SPEED
			if event.scancode == KEY_D:
				position.x += CURR_SPEED
			update()

	if event is InputEventMouseButton:
		if event.is_pressed():
			var mouse_pos = get_global_mouse_position()
			if event.button_index == BUTTON_WHEEL_UP: # ZOOM OUT
				var new_zoom = zoom * VECTOR_ZOOM
				position = (position - mouse_pos) * new_zoom / zoom + mouse_pos
				zoom = new_zoom
				update()
			if event.button_index == BUTTON_WHEEL_DOWN: # ZOOM IN
				var new_zoom = zoom / VECTOR_ZOOM
				position = (position - mouse_pos) * new_zoom / zoom + mouse_pos
				zoom = new_zoom
				update()

func draw_grid():
	var res = get_viewport_rect().size
	res *= zoom
	var CURR_GAP = GAP * zoom.x
	
	var move_x = CURR_GAP - fposmod(position.x, CURR_GAP) 
	for i in range(0, ceil(res.x / GAP / zoom.x)): # VERTICAL
		var pos_x = i * CURR_GAP + move_x
		draw_line(Vector2(pos_x, 0), Vector2(pos_x, res.y), Color(0.4, 0.4, 0.4, 0.8), 1)
	
	CURR_GAP = GAP * zoom.y
	var move_y = CURR_GAP - fposmod(position.y, CURR_GAP)
	for i in range(0, ceil(res.y / GAP / zoom.y)): # HORIZONTAL
		var pos_y = i * CURR_GAP + move_y
		draw_line(Vector2(0, pos_y), Vector2(res.x, pos_y), Color(0.4, 0.4, 0.4, 0.8), 1)

func get_snap_point(point):
	var res = get_viewport_rect().size
	res *= zoom
	var CURR_GAP = GAP * zoom.x
	
	var snap_point = point
	
	var move_x = CURR_GAP - fposmod(position.x, CURR_GAP) 
	for i in range(0, ceil(res.x / GAP / zoom.x)): # VERTICAL
		var pos_x = i * CURR_GAP + move_x + position.x
		if abs(pos_x - point.x) <= SNAP_MARGIN:
			snap_point.x = pos_x
			break
	
	CURR_GAP = GAP * zoom.y
	var move_y = CURR_GAP - fposmod(position.y, CURR_GAP)
	for i in range(0, ceil(res.y / GAP / zoom.y)): # HORIZONTAL
		var pos_y = i * CURR_GAP + move_y + position.y
		if abs(pos_y - point.y) <= SNAP_MARGIN:
			snap_point.y = pos_y
			break
	return snap_point


func _draw():
	draw_grid()
