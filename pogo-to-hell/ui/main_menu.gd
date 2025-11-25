extends CanvasLayer


signal start_game
signal start_options
signal credits


func _on_start_button_pressed() -> void:
	start_game.emit()


func _on_options_button_pressed() -> void:
	start_options.emit()


func _on_credits_button_pressed() -> void:
	credits.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
