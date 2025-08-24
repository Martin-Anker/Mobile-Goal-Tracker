extends Node

var original_pos: Vector2
var shake_amount := 5        # Startstärke
var shake_intensity := 0.0
var shake_growth := 20.0     # Wie schnell der Shake stärker wird pro Sekunde
var daily_button_down := false
var button_fixed := false

var button_percent := 0
var tween: Tween
var wiggleTween: Tween

var offset = 0.1

var save_file := "user://days.json"

@onready var button = $Gamelayer/DailyButton
@onready var fill_layer = $Gamelayer/DailyButton/Filler

@onready var fill1 = $UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button4/Fill
@onready var fill2 = $UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button3/Fill
@onready var fill3 = $UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button2/Fill
@onready var fill4 = $UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button1/Fill
@onready var fill5 = $UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button0/Fill

func _ready() -> void:
	
	print(ProjectSettings.globalize_path("user://days.json"))
	
	fill_layer.scale = Vector2(0,0)
	original_pos = button.position
	
	if load_last_days(1)[0]:
		fix_button()
	else:
		save_today(false)
		
	
	update_timeline()
	set_streak_text()

func update_timeline():
	var save_state = load_last_days(5)
	
	if not save_state[0]:
		fill1.hide()
	if not save_state[1]:
		fill2.hide()
	if not save_state[2]:
		fill3.hide()
	if not save_state[3]:
		fill4.hide()
	if not save_state[4]:
		fill5.hide()
		
	if save_state[0]:
		$UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button4.is_fixed = true
		fill1.show()
	if save_state[1]:
		$UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button3.is_fixed = true
		fill2.show()
	if save_state[2]:
		$UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button2.is_fixed = true
		fill3.show()
	if save_state[3]:
		$UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button1.is_fixed = true
		fill4.show()
	if save_state[4]:
		$UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Button0.is_fixed = true
		fill5.show()

func _physics_process(delta: float) -> void:
	#$UI/MarginContainer/VBoxContainer/StreakLabel.text = str(button_percent)
	
	if button_percent >= 100 and not button_fixed:
		fix_button()
	
	if daily_button_down:
		shake_intensity += shake_growth * delta
	else:
		shake_intensity -= shake_growth * 5 * delta
	shake_intensity = clamp(shake_intensity, 0, 100)

func _on_button_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventScreenTouch and event.pressed: # Replace with function body.
		if button_fixed: return
		
		daily_button_down = true
		shake_intensity = 20
		wiggle()
		
		if tween: tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
		tween.set_ease(Tween.EASE_OUT) 
		
		tween.parallel().tween_property(self, "button_percent", 100, 5.0) # hoch in 3 Sekunden
		tween.parallel().tween_property(fill_layer, "scale", Vector2(0.9,0.9), 5.0) # hoch in 3 Sekunden
	elif event is InputEventScreenTouch and not event.pressed:
		if button_fixed: return
		
		daily_button_down = false
		if tween: tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
		tween.set_ease(Tween.EASE_OUT) 
		
		tween.parallel().tween_property(self, "button_percent", 0, 0.8)
		tween.parallel().tween_property(fill_layer, "scale", Vector2(0,0), 0.8)


func _on_button_area_mouse_exited() -> void:
		if button_fixed: return
		
		daily_button_down = false
		if tween: tween.kill()
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)       # Art der Kurve (SINE, QUAD, CUBIC, ELASTIC, …)
		tween.set_ease(Tween.EASE_OUT) 
		
		tween.parallel().tween_property(self, "button_percent", 0, 0.8)
		tween.parallel().tween_property(fill_layer, "scale", Vector2(0,0), 0.8)

func wiggle():
	
	if wiggleTween: wiggleTween.kill()
	
	var offset1 = randf_range(4.0, -4) * shake_intensity / 100
	var offset2 = randf_range(4.0, -4) * shake_intensity / 100

	wiggleTween = create_tween()
	wiggleTween.tween_property(button, "position", original_pos + Vector2(offset1, offset2), 0.04)

	if button_fixed: return
	wiggleTween.finished.connect(wiggle)

func change_offset():
	offset = randf_range(-40, 40)
	

func set_streak_text():
	$UI/MarginContainer/VBoxContainer/StreakLabel.text = "Streak: " + str(get_streak())

func fix_button():
	button_fixed = true
	daily_button_down = true
	
	save_today(true)
	update_timeline()
	set_streak_text()
	
	$Gamelayer/DailyButton/Confetti.emitting = true
	
	fill_layer.scale = Vector2(0.9, 0.9)

# Speichert für HEUTE den Wert (true/false)
func save_today(value: bool):
	var today = Time.get_datetime_string_from_system(false).substr(0, 10)  
	# ergibt z.B. "2025-08-22"

	var data = load_all_days()
	data[today] = value

	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file == null:
		print("FEHLER: Konnte Datei nicht öffnen!")
		return
	file.store_string(JSON.stringify(data))
	file.close()

# Lädt ALLE gespeicherten Tage
func load_all_days() -> Dictionary:
	if not FileAccess.file_exists(save_file):
		return {}
	var file = FileAccess.open(save_file, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data if typeof(data) == TYPE_DICTIONARY else {}

func save_day(offset: int, value: bool) -> void:
	# Heutige Zeit als Basis
	var now = Time.get_datetime_dict_from_system()
	var base_time = Time.get_unix_time_from_datetime_dict(now)

	# Offset in Tagen abziehen (offset=0 = heute, offset=1 = gestern)
	var day_time = base_time - offset * 86400
	var day_dict = Time.get_datetime_dict_from_unix_time(day_time)

	# Key bauen im selben Format wie bei load_last_days
	var key = str(day_dict.year) + "-" + str(day_dict.month).pad_zeros(2) + "-" + str(day_dict.day).pad_zeros(2)

	# Vorhandene Daten laden und aktualisieren
	var data = load_all_days()
	data[key] = value

	# Speichern
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	if file == null:
		print("FEHLER: Konnte Datei nicht öffnen!")
		return
	file.store_string(JSON.stringify(data))
	file.close()

# Gibt die letzten N Tage zurück
func load_last_days(n: int) -> Dictionary:
	var data = load_all_days()
	var result := {}

	var now = Time.get_datetime_dict_from_system()
	var base_time = Time.get_unix_time_from_datetime_dict(now)

	for i in range(n - 1, -1, -1):
		var day_time = base_time - i * 86400  # 86400 = Sekunden pro Tag
		var day_dict = Time.get_datetime_dict_from_unix_time(day_time)
		var key = str(day_dict.year) + "-" + str(day_dict.month).pad_zeros(2) + "-" + str(day_dict.day).pad_zeros(2)

		var idx = (n - 1) - i  # 0 = frühester, n-1 = heute
		if key in data:
			result[idx] = data[key]
		else:
			result[idx] = false
	return result
	
func get_streak():
	var data = load_all_days()
	var streak := 0

	var now = Time.get_datetime_dict_from_system()
	var base_time = Time.get_unix_time_from_datetime_dict(now)
	
	if data == {}:
		return 0
	
	print(data)
	
	for i in range(0, data.size()):
		var day_time = base_time - i * 86400  # 86400 = Sekunden pro Tag
		var day_dict = Time.get_datetime_dict_from_unix_time(day_time)
		var key = str(day_dict.year) + "-" + str(day_dict.month).pad_zeros(2) + "-" + str(day_dict.day).pad_zeros(2)
		var idx = (data.size() - 1) - i  # 0 = frühester, n-1 = heute
		if key in data and data[key]:
			streak += 1
			print("+1")
		else:
			if key == Time.get_datetime_string_from_system(false).substr(0, 10):
				streak += 0
				print("+0")
			else:
				print("ret 1")
				return streak
	print("ret 3")
	return streak
