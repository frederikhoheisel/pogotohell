extends Node


var show_main_menu: bool = true


var leaderboard: Array = [
	["MysteriousJuice", 27.92, 39200],
	["Goendyr", 37.12, 59200],
	["Zaubergurke", 39.95, 89200]
]


func add_to_leaderboard(score_name: String, time: float, score: int):
	leaderboard.append([score_name, time, score])
	sort_leaderboard()


func sort_leaderboard() -> void:
	leaderboard.sort_custom(func(a, b): return a[2] > b[2])
