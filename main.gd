extends Control

var original_pos: Vector2
var shake_amount := 5        # Startstärke
var shake_intensity := 0.0
var shake_growth := 20.0     # Wie schnell der Shake stärker wird pro Sekunde
var daily_button_down := false

var button_percent := 0
var tween: Tween

func _ready() -> void:
	$MarginContainer/VBoxContainer/Node2D/DailyButton/Fill.scale = Vector2(0,0)

func _on_daily_button_button_down() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
	tween.set_ease(Tween.EASE_OUT) 
	
	tween.parallel().tween_property(self, "button_percent", 100, 5.0) # hoch in 3 Sekunden
	tween.parallel().tween_property($MarginContainer/VBoxContainer/Node2D/DailyButton/Fill, "scale", Vector2(1,1), 5.0) # hoch in 3 Sekunden


func _on_daily_button_button_up() -> void:
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
	tween.set_ease(Tween.EASE_OUT) 
	
	tween.parallel().tween_property(self, "button_percent", 0, 0.8)
	tween.parallel().tween_property($MarginContainer/VBoxContainer/Node2D/DailyButton/Fill, "scale", Vector2(0,0), 0.8)

func _physics_process(delta: float) -> void:
	$MarginContainer/VBoxContainer/StreakLabel.text = str(button_percent)
	
	if daily_button_down:
		shake_intensity += shake_growth * delta
		var offset := Vector2(randf_range(-20, 20), randf_range(-20,20))
		add_theme_constant_override("margin_left", offset.x)
		add_theme_constant_override("margin_top", offset.y)
	else:
		# sanft zurück zur Originalposition
		add_theme_constant_override("margin_left", 0)
		add_theme_constant_override("margin_top", 0)
