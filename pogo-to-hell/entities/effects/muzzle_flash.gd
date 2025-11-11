extends Node3D


@onready var flash: GPUParticles3D = $Flash
@onready var sparks: GPUParticles3D = $Sparks


func fire() -> void:
	flash.restart()
	sparks.restart()
