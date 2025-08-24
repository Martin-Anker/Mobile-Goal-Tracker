extends TextureButton

var button_percent := 0
var tween: Tween

var is_fixed := false

func _ready():
	self.button_down.connect(self._on_down)
	self.button_up.connect(self._on_up)

func _physics_process(delta: float) -> void:
	if button_percent >= 100 and not is_fixed:
		fix_button()

func fix_button():
	is_fixed = true
	
	print("BUTTON FIXED!")
	
	var target = get_node("/root/Control")
	var day_index = int(name.replace("Button", ""))  # "Button3" -> 3
	target.save_day(day_index, true)
	
	target.update_timeline()
	target.set_streak_text()
	
	#$Gamelayer/DailyButton/Confetti.emitting = true
	
	$Fill.scale = Vector2(1, 1)

func _on_down():
	if is_fixed: return
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
	tween.set_ease(Tween.EASE_OUT) 
	
	$Fill.show()
	$Fill.scale = Vector2(0, 0)
	
	tween.parallel().tween_property(self, "button_percent", 100, 5.0) # hoch in 3 Sekunden
	tween.parallel().tween_property($Fill, "scale", Vector2(1, 1), 5.0) # hoch in 3 Sekunden

func _on_up():
	if is_fixed: return
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
	tween.set_ease(Tween.EASE_OUT) 
		
	tween.parallel().tween_property(self, "button_percent", 0, 0.8)
	tween.parallel().tween_property($Fill, "scale", Vector2(0,0), 0.8)
