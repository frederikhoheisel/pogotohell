extends CanvasLayer


@export var player: Player


@onready var progress_bar: ProgressBar = $ProgressBar


func _process(_delta: float) -> void:
	progress_bar.value = player.jump_strength * 100.0
