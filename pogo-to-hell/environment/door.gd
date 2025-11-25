extends Node3D

func open() -> void:
	$skull/AnimationPlayer.play("Armature|ArmatureAction")
	$jaw/AnimationPlayer.play("Armature_001|Armature_001Action")
	
