extends Node2D

var current_map = null
var current_bezier = null

var STEPS = 100
var WIDTH = 5

var SELECTION_DISTANCE = 9

var selection = null
var pressed = false

onready var MAP_SCRIPT = load("res://Map creator/map.gd")

onready var grid = get_node("Camera2D")
onready var popup = get_node("CenterContainer/Popup")
onready var line_edit = get_node("CenterContainer/Popup/LineEdit")

func _ready():
	line_edit.connect("text_entered", self, "save_map")
	create_map()

func _input(event):
	var ctrl = Input.is_key_pressed(KEY_CONTROL)
	var save = Input.is_action_just_pressed("MAP_SAVE")
	var create = Input.is_action_just_pressed("MAP_CREATE")
	if create:
		if current_map:
			create_bezier()
	if ctrl and save:
		name_map()
	
	var mouse_pos = get_global_mouse_position()
	
	# CHANGE POSITION OF POINT
	if pressed:
		if selection != null:
			selection.set_position(grid.get_snap_point(mouse_pos))
			update()
	
	if event is InputEventMouseButton:
		if event.pressed:
			if current_bezier:
				selection = get_point_on_cursor(mouse_pos)
				if event.button_index == BUTTON_LEFT:
					pressed = true
					if selection == null and current_bezier.get_child_count() < 4: # max bezier points = 4
						create_point()
				elif event.button_index == BUTTON_RIGHT:
					if selection:
						selection.free()
						update()
		else:
			selection = null
			pressed = false

func create_map():
	if current_map:
		current_map.queue_free()
		update()
	current_map = StaticBody2D.new()
	current_map.set_script(MAP_SCRIPT)
	add_child(current_map)

func create_bezier():
	var name = "bezier_" + str(current_map.get_child_count())
	var bezier = Node2D.new()
	bezier.name = name
	
	current_map.add_child(bezier)
	bezier.set_owner(current_map) # for saving
	
	current_bezier = bezier

func create_point():
	var name = "point_" + str(current_bezier.get_child_count())
	var point = Node2D.new()
	point.name = name
	point.position = grid.get_snap_point(get_global_mouse_position())
	current_bezier.add_child(point)
	point.set_owner(current_map) # for saving
	update()

func save_map(map_name):
	current_map.name = map_name
	var packed_map = PackedScene.new()
	packed_map.pack(current_map)
	ResourceSaver.save("res://Maps/" + map_name + ".tscn", packed_map)
	popup.hide()
	create_map()

# for naming current map to save
func name_map():
	popup.popup_centered()


# POINTS
func get_point_on_cursor(mouse_pos):
	for bezier in current_map.get_children():
		for point in bezier.get_children():
			if mouse_pos.distance_to(point.position) < SELECTION_DISTANCE:
				return point
	return null


func _draw():
	if current_map:
		current_map.update()
		draw_helpers()


# HELPERS
func draw_helpers():
	var beziers = current_map.get_children()
	for bezier in beziers:
		var points = bezier.get_children()
		draw_points(points)
		draw_helper_lines(points)

func draw_points(points):
	for point in points:
		draw_circle( point.position, SELECTION_DISTANCE, Color( 1.0, 0.5, 0.5, 0.6 ) )

func draw_helper_lines(points):
	for i in range(len(points)-1):
		draw_line(points[i].position, points[i+1].position, Color( 1, 1, 1, 0.5 ), 1 )