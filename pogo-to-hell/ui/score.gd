extends CanvasLayer

var total_score: int
var current_combo: int
var current_multiplier: float = 1.0
var current_dmg_combo_length: int
var current_kill_combo_length: int
var current_jump_combo_length: int
@export var combo_time: float = 3.0

var in_air: bool = true

func _ready() -> void:
	pass #$ComboTimer.wait_time = combo_time


func _process(_delta: float) -> void:
	$VBoxContainer/ComboTimoutBar.value = $ComboTimer.time_left
	if (%TotalScore.text.to_int() < total_score):
		var new_shown_score: int =  lerp(%TotalScore.text.to_int(), total_score, 0.5)
		%TotalScore.text = str(new_shown_score)
	

func increase_combo(kill: bool) -> void:
	print("call increase_combo")
	if $ComboTimer.is_stopped(): start_combo()
	else: reset_timer()
	var new_combo_points
	if kill:
		current_kill_combo_length += 1
		current_dmg_combo_length += 1
		new_combo_points = 30
		current_multiplier += pow(0.8, float(current_kill_combo_length)) * 2.0
		set_kill_trick()
	else:
		current_dmg_combo_length += 1
		new_combo_points= 10
		current_multiplier += pow(0.8, float(current_dmg_combo_length)) * 1.0
		set_hit_trick()
	if in_air: new_combo_points *= 1.5
	current_combo += new_combo_points
	update_combo_labels()
	

	
func start_combo() -> void:
	$ComboTimer.start()

func reset_timer() -> void:
	$ComboTimer.start()

func pause_combo() -> void:
	$ComboTimer.paused = true
	
func continue_combo() -> void:
	$ComboTimer.paused = false
	
func end_combo() -> void:
	$ComboTimer.stop()
	add_to_score()
	current_combo = 0
	current_multiplier = 1.0
	current_dmg_combo_length = 0
	current_kill_combo_length = 0
	current_jump_combo_length = 0
	%Current_Combo.text = " "
	%Multiplier.text = " "
	$VBoxContainer/Current_Trick.text = " "
	

func add_to_score() -> void:
	total_score += (int)(current_combo * current_multiplier)
	

func _on_combo_timer_timeout() -> void:
	print("combo timer timeout")
	end_combo()

func update_combo_labels() -> void:
	%Current_Combo.set_text(str(snapped(current_combo, 0.01)))
	pop(%Current_Combo, Color.GREEN, 1.0)
	%Multiplier.set_text("X " + str(snapped(current_multiplier, 0.01)))
	pop(%Multiplier, Color.MEDIUM_SPRING_GREEN, 1.0)
	#%TotalScore.set_text(str(total_score))

func set_kill_trick() -> void:
	$VBoxContainer/Current_Trick.add_theme_font_size_override("font_size", 25 + 2 * current_kill_combo_length)
	var current_trick = ""
	match current_kill_combo_length:
		1: current_trick = "Kill"
		2: current_trick = "Doublekill"
		3: current_trick = "Triplekill"
		4: current_trick = "CARNAGE!"
	$VBoxContainer/Current_Trick.text = current_trick
	pop($VBoxContainer/Current_Trick, Color.DARK_RED, 1.5)
	
func jump() -> void:
	current_jump_combo_length += 1
	reset_timer()
	$VBoxContainer/Current_Trick.add_theme_font_size_override("font_size", 25)
	$VBoxContainer/Current_Trick.text = "Jump x " + str(current_jump_combo_length)
	pop($VBoxContainer/Current_Trick, Color.DARK_ORANGE, 1.2)
	
func set_hit_trick() -> void:
	$VBoxContainer/Current_Trick.add_theme_font_size_override("font_size", 25 + current_dmg_combo_length)
	$VBoxContainer/Current_Trick.text = "Hit X " + str(current_dmg_combo_length)
	pop($VBoxContainer/Current_Trick, Color.ORANGE_RED, 1.3)
	
	
func pop(label: Label, color: Color, scale:float) -> void:
	label.modulate = Color.WHITE
	label.scale = Vector2(0.2, 0.2)
	var tween1 = get_tree().create_tween()
	tween1.set_parallel()
	tween1.tween_property(label, "modulate", color, 0.2)
	tween1.tween_property(label, "scale", Vector2(scale, scale), 0.2)
	
	#var tween2 = get_tree().create_tween()
	#tween2.set_parallel()
	#tween2.tween_property(label, "modulate", Color.WHITE, 0.4)
	#tween2.tween_property(label, "scale", Vector2(1.0, 1.0), 0.4)
