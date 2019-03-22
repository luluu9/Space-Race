extends Camera2D

var GAP = 50
var SPEED = 15

var SNAP_MARGIN = 5 # on one side, totally SNAP_MARGIN * 2

func _process(delta):
	if Input.is_key_pressed(KEY_W):
		position.y -= SPEED
	if Input.is_key_pressed(KEY_S):
		position.y += SPEED
	if Input.is_key_pressed(KEY_A):
		position.x -= SPEED
	if Input.is_key_pressed(KEY_D):
		position.x += SPEED
	update()

func draw_grid():
	var res = get_viewport_rect().size
	res.x *= zoom.x
	res.y *= zoom.y

	var move_x = GAP - fposmod(position.x, GAP)
	for i in range(0, ceil(res.x / GAP)): # VERTICAL
		var pos_x =  i * GAP + move_x # + position.x
		draw_line(Vector2(pos_x, 0), Vector2(pos_x, res.y), Color(0.4, 0.4, 0.4, 0.8), 1)
	
	var move_y = GAP - fposmod(position.y, GAP)
	for i in range(0, ceil(res.y / GAP)): # HORIZONTAL
		var pos_y =  i * GAP + move_y # + position.x
		draw_line(Vector2(0, pos_y), Vector2(res.x, pos_y), Color(0.4, 0.4, 0.4, 0.8), 1)

func get_snap_point(point):
	var res = get_viewport_rect().size
	res.x *= zoom.x
	res.y *= zoom.y
	
	var snap_point = point
	#var on_grid = false
	
	var move_x = GAP - fposmod(position.x, GAP)
	for i in range(0, ceil(res.x / GAP)): 
		var pos_x =  i * GAP + move_x + position.x
		if abs(pos_x - point.x) <= SNAP_MARGIN:
			snap_point.x = pos_x
			#on_grid = true
			break

	var move_y = GAP - fposmod(position.y, GAP)
	for i in range(0, ceil(res.y / GAP)):
		var pos_y =  i * GAP + move_y + position.x
		if abs(pos_y - point.y) <= SNAP_MARGIN:
			snap_point.y = pos_y
			#on_grid = true
			break
	return snap_point


func _draw():
	draw_grid()