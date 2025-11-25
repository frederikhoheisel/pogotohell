extends Control


signal name_entered(score_name: String)


@onready var text_edit: LineEdit = $PanelContainer/VBoxContainer/TextEdit


func _on_button_pressed() -> void:
	if text_edit.text.length() > 20 || text_edit.text.length() <= 0:
		return
	
	name_entered.emit(text_edit.text)
	self.hide()


func _on_text_edit_text_submitted(_new_text: String) -> void:
	_on_button_pressed()
