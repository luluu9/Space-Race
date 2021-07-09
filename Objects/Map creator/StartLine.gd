extends Area2D

onready var texture_rect = $TextureRect
onready var collision_shape = $CollisionShape2D


func _ready():
	change_size(Vector2(100, 100))


func change_size(new_size):
	# texture rect does not allow negative size, thus Rect2D covers this aspect
	# with the abs() method
	var texture_new_rect = Rect2(position, new_size).abs()
	texture_rect.rect_position = texture_new_rect.position-position
	texture_rect.rect_size = texture_new_rect.size*10
	collision_shape.shape.extents = new_size/2
	collision_shape.position = new_size/2

