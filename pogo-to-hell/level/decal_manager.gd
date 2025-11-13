extends Node


@export var max_decals: int = 50


var decal: PackedScene = preload("res://entities/effects/decal.tscn")
var decals: Array[Node3D]


func place_decal(collision_point: Vector3, collision_normal: Vector3) -> void:
	var decal_instance: Node3D
	if len(decals) >= max_decals and is_instance_valid(decals[0]):
		decal_instance = decals.pop_front()
		decals.push_back(decal_instance)
	else:
		decal_instance = decal.instantiate()
		self.add_child(decal_instance)
		decals.push_back(decal_instance)
	
	if not is_instance_valid(decals[0]):
		decals.pop_front()
	
	decal_instance.global_position = collision_point
	
	if (collision_normal).cross(Vector3.UP).is_equal_approx(Vector3.ZERO):
		decal_instance.look_at(collision_point - collision_normal, Vector3.FORWARD)
	else:
		decal_instance.look_at(collision_point - collision_normal)
		
	decal_instance.get_node("GPUParticles3D").restart()
