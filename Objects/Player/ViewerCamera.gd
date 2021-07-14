extends Camera2D

onready var camera_x = get_camera_size().x
onready var camera_y = get_camera_size().y

var MARGIN = 200


func _process(delta):
	set_camera_position()
	

func set_camera_position():
	var rect_to_show = get_players_rect()
	var camera_ratio_x = rect_to_show.size.x/camera_x
	var camera_ratio_y = rect_to_show.size.y/camera_y
	# choose bigger ratio to preserve screen resolution ratio
	if camera_ratio_x > camera_ratio_y:
		self.zoom = Vector2(camera_ratio_x, camera_ratio_x)
	else:
		self.zoom = Vector2(camera_ratio_y, camera_ratio_y)
	self.offset = rect_to_show.position


# returns rect of players positions expanded by MARGIN variable
func get_players_rect():
	var players = get_tree().get_nodes_in_group("Players")
	var players_rect = Rect2(players[0].position, Vector2(0, 0))
	# when only one player, center camera on him
	if len(players) == 1:
		var start_pos = players[0].position-Vector2(camera_x, camera_y)/4
		players_rect = Rect2(start_pos, Vector2(camera_x, camera_y)/2) # half only to zoom in the player
		return players_rect
	# expand rect for each player
	for player in players:
		players_rect = players_rect.expand(player.position)
	# grow rect in every side by MARGIN
	players_rect = players_rect.grow(MARGIN)
	return players_rect


# https://godotengine.org/qa/13740/get-camera-extents-rect-2d
func get_camera_size():
	# Get the canvas transform
	var ctrans = get_canvas_transform()
	# The canvas transform applies to everything drawn,
	# so scrolling right offsets things to the left, hence the '-' to get the world position.
	# Same with zoom so we divide by the scale.
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	# The maximum edge is obtained by adding the rectangle size.
	# Because it's a size it's only affected by zoom, so divide by scale too.
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	var max_pos = min_pos + view_size
	return max_pos
