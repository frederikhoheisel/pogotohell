extends Node3D


@export var enemies: Array[Broski]


var open: bool = false


func _open() -> void:
	$skull/AnimationPlayer.play("Armature|ArmatureAction")
	$jaw/AnimationPlayer.play("Armature_001|Armature_001Action")
	$StaticBody3D/CollisionShape3D.disabled = true


func _physics_process(_delta: float) -> void:
	if open:
		return
	
	for i: int in enemies.size():
		if not is_instance_valid(enemies[i]):
			enemies.remove_at(i)
	
	if enemies.size() <= 0:
		open = true
		_open()
