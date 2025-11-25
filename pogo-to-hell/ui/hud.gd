extends CanvasLayer


@export var player: Player


var tween: Tween


@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var debug_label_1: Label = $DebugLabel1
@onready var debug_label_2: Label = $DebugLabel2
@onready var debug_label_3: Label = $DebugLabel3
@onready var settings_menu: CanvasLayer = $SettingsMenu
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var intro: CanvasLayer = $Intro
@onready var main_menu: CanvasLayer = $MainMenu
@onready var hit_color_rect: TextureRect = %HitColorRect
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var grapple_bar: TextureProgressBar = %GrappleBar


func _ready() -> void:
	player.damage_taken.connect(_on_player_damage)
	player.player_died.connect(_on_player_died)
	
	if Globals.show_main_menu:
		get_tree().paused = true
		main_menu.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_menu.visible:
			settings_menu.visible = false
			return
		
		pause_menu.paused = not pause_menu.paused
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if pause_menu.paused else Input.MOUSE_MODE_CAPTURED)
		pause_menu.visible = pause_menu.paused
		get_tree().paused = pause_menu.paused


func _process(_delta: float) -> void:
	health_bar.value = player.health
	progress_bar.value = player.jump_strength * 100.0
	grapple_bar.value = player.get_node("Shooting").grapple_time * 2.0
	debug_label_1.text = "player speed:  " + str(player.velocity.length())
	debug_label_2.text = "grapple_time:  " + str(player.get_node("Shooting").grapple_time)
	debug_label_3.text = "fps:  " + str(Engine.get_frames_per_second())


func _on_pause_menu_settings_pressed(toggled_on: bool) -> void:
	settings_menu.visible = toggled_on


func _on_player_damage() -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	
	hit_color_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	tween.tween_property(hit_color_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _on_player_died() -> void:
	Globals.show_main_menu = false
	get_tree().call_deferred("reload_current_scene")


func _on_intro_intro_finished() -> void:
	get_tree().paused = false
	pause_menu.hide()
	intro.hide()


func _on_main_menu_start_game() -> void:
	main_menu.hide()
	pause_menu.show()
	intro.show()
	intro.start()


func _on_main_menu_start_options() -> void:
	settings_menu.visible = true


func _on_main_menu_credits() -> void:
	pass # TODO
