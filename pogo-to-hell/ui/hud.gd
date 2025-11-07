extends CanvasLayer


@export var player: Player


@onready var progress_bar: ProgressBar = $ProgressBar
@onready var debug_label_1: Label = $DebugLabel1
@onready var debug_label_2: Label = $DebugLabel2
@onready var debug_label_3: Label = $DebugLabel3
@onready var settings_menu: CanvasLayer = $SettingsMenu
@onready var pause_menu: CanvasLayer = $PauseMenu


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		print(event)
		if pause_menu.settings_shown:
			_on_pause_menu_settings_pressed(false)
			pause_menu.settings_shown = false
		
		pause_menu.paused = not pause_menu.paused
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if pause_menu.paused else Input.MOUSE_MODE_CAPTURED)
		pause_menu.visible = pause_menu.paused
		get_tree().paused = pause_menu.paused


func _process(_delta: float) -> void:
	progress_bar.value = player.jump_strength * 100.0
	debug_label_1.text = "player speed:  " + str(player.velocity.length())
	debug_label_2.text = "on wall:  " + str(player.on_wall)
	debug_label_3.text = "fps:  " + str(Engine.get_frames_per_second())


func _on_pause_menu_settings_pressed(toggled_on: bool) -> void:
	settings_menu.visible = toggled_on
