extends CanvasLayer


signal settings_pressed(toggled_on: bool)


var paused: bool = false
var settings_shown: bool = false


func _on_settings_button_pressed() -> void:
	settings_pressed.emit(true)
	settings_shown = true


func _on_resume_button_pressed() -> void:
	paused = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = paused
	get_tree().paused = paused


func _on_exit_button_pressed() -> void:
	get_tree().quit()
