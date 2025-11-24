extends Node3D


@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D


func smoke_away(explosive: bool, size: float) -> void:
	gpu_particles_3d.explosiveness = 0.9 if explosive else 0.0
	gpu_particles_3d.one_shot = explosive
	gpu_particles_3d.process_material.set("emission_sphere_radius", size)
	gpu_particles_3d.draw_pass_1.radius = size * 0.5
	gpu_particles_3d.draw_pass_1.height = size
	
	gpu_particles_3d.restart()
