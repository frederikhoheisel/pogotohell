extends Node3D


@onready var animation_player: AnimationPlayer = $arm_view_model/AnimationPlayer
@onready var revolver: Node3D = $arm_view_model/Arm_Rig/Skeleton3D/BoneAttachment3D/revolver
@onready var muzzle_flash: Node3D = %MuzzleFlash


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_pull_out_anim()


func play_fire_anim() -> void:
	muzzle_flash.fire()
	animation_player.stop()
	animation_player.play("ArmViewModel/view_model_shoot")
	animation_player.queue("ArmViewModel/view_model_idle")


func play_pull_out_anim() -> void:
	var tween: Tween = get_tree().create_tween()
	revolver.rotation_degrees = Vector3(-88.8, -162.7, 66.7)
	tween.tween_property(revolver, "rotation", revolver.rotation + Vector3(2.0 * PI, 0.0, 0.0), 0.3)
	
	
	animation_player.play("ArmViewModel/view_model_pull_out")
	animation_player.queue("ArmViewModel/view_model_idle")
