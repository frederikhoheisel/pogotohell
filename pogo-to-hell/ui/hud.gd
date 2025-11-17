extends CanvasLayer


@export var player: Player


var tween: Tween


@onready var progress_bar: ProgressBar = $ProgressBar
@onready var debug_label_1: Label = $DebugLabel1
@onready var debug_label_2: Label = $DebugLabel2
@onready var debug_label_3: Label = $DebugLabel3
@onready var settings_menu: CanvasLayer = $SettingsMenu
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var hit_color_rect: TextureRect = %HitColorRect
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	player.damage_taken.connect(_on_player_damage)


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
	debug_label_1.text = "player speed:  " + str(player.velocity.length())
	debug_label_2.text = "on wall:  " + str(player.on_wall)
	debug_label_3.text = "fps:  " + str(Engine.get_frames_per_second())


func _on_pause_menu_settings_pressed(toggled_on: bool) -> void:
	settings_menu.visible = toggled_on


func _on_player_damage() -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	
	hit_color_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	tween.tween_property(hit_color_rect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.7).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
