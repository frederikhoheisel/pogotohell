extends CanvasLayer


@export var player: Player


@onready var progress_bar: ProgressBar = $ProgressBar
@onready var debug_label_1: Label = $DebugLabel1
@onready var debug_label_2: Label = $DebugLabel2
@onready var debug_label_3: Label = $DebugLabel3


func _process(_delta: float) -> void:
	progress_bar.value = player.jump_strength * 100.0
	debug_label_1.text = "player speed:  " + str(player.velocity.length())
	debug_label_2.text = "on wall:  " + str(player.on_wall)
	debug_label_3.text = "jump buffered:  " + str(player.jump_buffered)
