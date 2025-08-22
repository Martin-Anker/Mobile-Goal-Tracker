extends TextureButton

func _process(delta: float) -> void:
	$CanvasLayer/Node2D/Confetti.position = global_position + size / 2
