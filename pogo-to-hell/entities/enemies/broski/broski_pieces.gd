extends Node3D


@export var intensity: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for piece: RigidBody3D in self.get_children():
		piece.apply_impulse(piece.get_child(0).position * intensity, self.global_position)
	
	await get_tree().create_timer(3.0).timeout
	
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel(true)
	for piece: RigidBody3D in self.get_children():
		tween.tween_property(piece.get_child(0), "scale", Vector3(0.05, 0.05, 0.05), 0.2)
	
	await get_tree().create_timer(0.2).timeout
	
	queue_free()
