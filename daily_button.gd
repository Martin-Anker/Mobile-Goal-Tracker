extends Node2D

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	
	position = Vector2(screen_size.x * 0.5, screen_size.y * 0.3)
	scale = Vector2.ONE * (screen_size.y * 0.3 / $Circle.texture.get_size().y)  # z.B. 20% der Höhe
