extends Node3D


@onready var animation_player: AnimationPlayer = $arm_view_model/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_pull_out_anim()


func play_fire_anim() -> void:
	animation_player.stop()
	animation_player.play("ArmViewModel/view_model_shoot")
	animation_player.queue("ArmViewModel/view_model_idle")


func play_pull_out_anim() -> void:
	animation_player.play("ArmViewModel/view_model_pull_out")
	animation_player.queue("ArmViewModel/view_model_idle")
