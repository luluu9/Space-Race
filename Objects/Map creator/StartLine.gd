extends Area2D

var texture_rect = null
var collision_shape = null

func _ready():
	# because of two same nodes, we have to eliminate default ones
	var children = get_children()
	if len(children) == 4:
		for i in range(2):
			children[i].free()
	texture_rect = $TextureRect
	collision_shape = $CollisionShape2D
	update_collision_shape()


func change_size(new_size):
	# texture rect does not allow negative size, thus Rect2D covers this aspect
	# with the abs() method
	var texture_new_rect = Rect2(position, new_size).abs()
	texture_rect.rect_position = texture_new_rect.position-position
	texture_rect.rect_size = texture_new_rect.size*10
	collision_shape.shape.extents = new_size/2
	collision_shape.position = new_size/2


func update_collision_shape():
	var new_size = get_texture_rect_real().size
	collision_shape.shape.extents = new_size/2
	collision_shape.position = new_size/2


# returns rect of texture appropriate to scale property
func get_texture_rect_real():
	var rect = texture_rect.get_rect()
	rect.size /= 10
	rect.position /= 10
	return rect
