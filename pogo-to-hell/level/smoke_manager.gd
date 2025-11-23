extends Node


@export var max_smoke_particles: int = 50


var smoke: PackedScene = preload("res://entities/effects/smoke_explosion.tscn")
var smokes: Array[Node3D]


func place_smoke(collision_point: Vector3, explosive: bool, size: float) -> void:
	var smoke_instance: Node3D
	if len(smokes) >= max_smoke_particles and is_instance_valid(smokes[0]):
		smoke_instance = smokes.pop_front()
		smokes.push_back(smoke_instance)
	else:
		smoke_instance = smoke.instantiate()
		self.add_child(smoke_instance)
		smokes.push_back(smoke_instance)
	
	if not is_instance_valid(smokes[0]):
		smokes.pop_front()
	
	smoke_instance.global_position = collision_point
	
	smoke_instance.smoke_away(explosive, size)
