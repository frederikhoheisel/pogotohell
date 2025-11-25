extends CanvasLayer


var score_scene: PackedScene = preload("res://ui/score_line.tscn")


@onready var score_container: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/VBoxContainer


func update_score() -> void:
	var place: int = 1
	for score in Globals.leaderboard:
		var s: HBoxContainer = score_scene.instantiate()
		s.place = place
		s.score_name = score[0]
		s.time = score[1]
		s.score = score[2]
		score_container.add_child(s)
		place += 1


func _on_enter_name_name_entered(score_name: String) -> void:
	Globals.add_to_leaderboard(score_name, 0.0, 10)
	update_score()


func _on_button_pressed() -> void:
	Globals.show_main_menu = true
	get_tree().call_deferred("reload_current_scene")
