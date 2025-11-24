extends Node3D

func _ready() -> void:
	pass
	
func start_bleeding() -> void:
	$BloodBurst.emitting = true
	
func stop_bleeding() -> void:
	$BloodBurst.emitting = false
