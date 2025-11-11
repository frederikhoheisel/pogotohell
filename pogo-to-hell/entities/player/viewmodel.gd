extends Node3D


@onready var animation_player: AnimationPlayer = $arm_view_model/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("ArmViewModel/view_model_idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		animation_player.play("ArmViewModel/view_model_shoot")
		animation_player.queue("ArmViewModel/view_model_idle")
	
	if event.is_action_pressed("pull_out"):
		animation_player.play("ArmViewModel/view_model_pull_out")
		animation_player.queue("ArmViewModel/view_model_idle")
