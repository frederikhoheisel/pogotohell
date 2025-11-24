extends Node


@export var max_smoke_particles: int = 50


var smoke: PackedScene = preload("res://entities/effects/smoke_explosion.tscn")
var blood_expl: PackedScene = preload("res://entities/effects/blood_expl_particles.tscn")
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

func place_blood_expl(death_pos: Vector3) -> void:
	var blood_instance: GPUParticles3D = blood_expl.instantiate()
	blood_instance.position = Vector3(death_pos.x, death_pos.y + 1.0, death_pos.z)
	self.add_child(blood_instance)
