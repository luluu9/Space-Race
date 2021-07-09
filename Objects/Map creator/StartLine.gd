extends Area2D

onready var textureRect = $TextureRect
onready var collisionShape2D = $CollisionShape2D


func _ready():
	change_size(Vector2(500, 100))


func change_size(new_size):
	textureRect.rect_size = new_size*10
	collisionShape2D.shape.extents = new_size/2
	collisionShape2D.position = new_size/2

