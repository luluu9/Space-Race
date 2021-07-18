extends Node2D

### MAP CREATOR ###
# To create new map save existing by CTRL+S
# To create new bezier points use LMB
# To create new bezier line use N
# To create new bezier use N
# To create spawnpoint use M
# To create bubble use B
# To delete bubble use SHIFT+LMB
# To delete bezier point use SHIFT+LMB
# To change current bezier use RMB
# To change an existing map put a map scene into the inspector variable current_map

export (PackedScene) var current_map = null
var current_bezier = null
var current_startpoint = null

var SELECTION_DISTANCE = 9

var selection = null
var pressed = false

onready var MAP_SCRIPT = load("res://Objects/Map creator/Map.gd")
onready var BEZIER_SCRIPT = load("res://Objects/Map creator/Bezier.gd")

onready var grid = get_node("Camera2D")
onready var popup = get_node("CanvasLayer/Popup")
onready var line_edit = get_node("CanvasLayer/Popup/LineEdit")

onready var bubble_scene = load("res://Objects/Items/Bubble.tscn")
var bubble_radius = null
var current_bubble = null

onready var start_line_scene = load("res://Objects/Map creator/StartLine.tscn")
var current_start_line = null
var start_line_editing = false


func _ready():
	line_edit.connect("text_entered", self, "save_map")
	if current_map:
		current_map = current_map.instance()
		var beziers = current_map.get_beziers()
		if beziers:
			current_bezier = beziers[0]
		current_start_line = current_map.get_node_or_null("start_line")
		add_child(current_map)
	else:
		create_map()


func _input(event):
	var ctrl = Input.is_key_pressed(KEY_CONTROL)
	var shift = Input.is_key_pressed(KEY_SHIFT)
	var lmb = Input.is_mouse_button_pressed(BUTTON_LEFT)
	var save = Input.is_action_just_pressed("MAP_SAVE")
	var create_bezier = Input.is_action_just_pressed("MAP_CREATE_BEZIER")
	var create_bubble = Input.is_action_just_pressed("MAP_CREATE_BUBBLE")
	var create_startpoint = Input.is_action_just_pressed("MAP_STARTPOINT")
	var create_startline = Input.is_action_just_pressed("MAP_CREATE_STARTLINE")
	var mouse_pos = get_global_mouse_position()
	current_bubble = get_bubble_on_mouse()
	if line_edit.get_focus_owner():
		return
	if create_bezier: # CREATE BEZIER
		if current_map:
			create_bezier()
	elif create_bubble:
		create_bubble()
	elif create_startpoint:
		create_startpoint()
	elif ctrl and save:
		name_map()
	elif ctrl and current_bubble: 
		current_bubble.queue_free()
	elif current_bubble and lmb:
		current_bubble.position = mouse_pos
		return # to prevent creating new bezier points
	elif current_bubble and shift:
		current_bubble.queue_free()
	elif create_startline:
		create_start_line()
	
	if start_line_editing:
		var start_line_size = grid.get_snap_point(mouse_pos) - current_start_line.position
		current_start_line.change_size(start_line_size)
		if lmb: # stop editing start line
			start_line_editing = false
		return
	
	# CHANGE POSITION OF POINT
	if pressed:
		if selection != null:
			selection.set_position(grid.get_snap_point(mouse_pos))
			update()
	
	if event is InputEventMouseButton:
		if event.pressed:
			if current_bezier:
				selection = get_point_on_cursor(mouse_pos)
				if event.button_index == BUTTON_LEFT and shift: # DELETE BEZIER POINT
					if selection:
						selection.free()
						update()
				elif event.button_index == BUTTON_LEFT: # ADD BEZIER POINT
					pressed = true
					if selection == null and current_bezier.get_child_count() < 4: # max bezier points = 4
						create_point()
				elif event.button_index == BUTTON_RIGHT:  # CHANGE CURRENT BEZIER
					if selection:
						current_bezier = selection.get_parent()
		else:
			selection = null
			pressed = false


func create_map():
	if current_map:
		current_map.queue_free()
		update()
	current_map = StaticBody2D.new()
	current_map.set_script(MAP_SCRIPT)
	create_startpoint()
	
	add_child(current_map)


func create_bezier():
	var name = "bezier_" + str(current_map.get_child_count())
	var bezier = Node2D.new()
	bezier.set_script(BEZIER_SCRIPT)
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


func create_startpoint():
	if current_startpoint:
		current_startpoint.free()
	current_startpoint = Node2D.new()
	current_startpoint.name = "startpoint"
	current_startpoint.position = grid.get_snap_point(get_global_mouse_position())
	
	current_map.add_child(current_startpoint)
	current_startpoint.set_owner(current_map) # for saving
	update()


func create_start_line():
	if current_start_line:
		current_start_line.free()
	current_start_line = start_line_scene.instance()
	current_start_line.name = "start_line"
	current_start_line.position = grid.get_snap_point(get_global_mouse_position())
	
	current_map.add_child(current_start_line)
	# there is some unexpected behaviour: properties of start_line children nodes
	# are not saved, we have to call set_owner of these nodes to current_map
	# but it creates copy of them instead of changing owner
	# // to investigate, currently works as workaround
	for node in current_start_line.get_children():
		node.set_owner(current_map)
	current_start_line.set_owner(current_map) # for saving
	start_line_editing = true


func create_bubble():
	var new_bubble = bubble_scene.instance()
	new_bubble.position = grid.get_snap_point(get_global_mouse_position())
	current_map.add_child(new_bubble)
	new_bubble.set_owner(current_map)


func save_map(map_name):
	current_map.name = map_name
	var packed_map = PackedScene.new()
	packed_map.pack(current_map)
	ResourceSaver.save("res://Objects/Maps/" + map_name + ".tscn", packed_map)
	popup.hide()
	create_map()


# for naming current map to save
func name_map():
	popup.popup()


# POINTS
func get_point_on_cursor(mouse_pos):
	for bezier in current_map.get_beziers():
		for point in bezier.get_children():
			if mouse_pos.distance_to(point.position) < SELECTION_DISTANCE:
				return point
	return null


# GETTING BUBBLES
func get_bubble_on_mouse():
	var mouse_pos = get_global_mouse_position()
	for node in current_map.get_children():
		if "Bubble" in node.name:
			if not bubble_radius:
				bubble_radius = node.get_node("CollisionShape2D").shape.radius
			if abs((node.position - mouse_pos).length()) < bubble_radius:
				return node


func _draw():
	if current_map:
		current_map.update()
		draw_helpers()


# HELPERS
func draw_helpers():
	if current_startpoint:
		draw_startpoint(current_startpoint.position)
	for bezier in current_map.get_beziers():
		var points = bezier.get_points()
		draw_points(points)
		draw_helper_lines(points)


func draw_startpoint(point):
	draw_circle(point, SELECTION_DISTANCE, Color("74f442"))


func draw_points(points):
	for point in points:
		draw_circle(point, SELECTION_DISTANCE, Color(1.0, 0.5, 0.5, 0.6))


func draw_helper_lines(points):
	for i in range(len(points)-1):
		draw_line(points[i], points[i+1], Color( 1, 1, 1, 0.5 ), 1 )
