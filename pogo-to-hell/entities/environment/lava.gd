@tool
extends Node3D


@export var width: float = 1.0:
	set(v):
		width = v
		_update()
@export var height: float = 1.0:
	set(v):
		height = v
		_update()
@export var depth: float = 1.0:
	set(v):
		depth = v
		_update()

@export var damage_per_tick: int = 1
@export var damage_interval: float = 0.5
@export var speed: Vector3


var player: Player
var player_inside: bool = false
var time: float = 0.0
var offset: Vector3 = Vector3.ZERO


@onready var collision_shape_3d: CollisionShape3D = %CollisionShape3D
@onready var lava_mesh: MeshInstance3D = %LavaMesh


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	offset = Vector3.ZERO
	_update()


func _physics_process(delta: float) -> void:
	offset += speed * delta
	lava_mesh.mesh.material.albedo_texture.noise.offset = offset
	
	if not player_inside:
		return
	
	time += delta
	if time > damage_interval:
		time = 0.0
		player.take_damage(damage_per_tick)


func _update() -> void:
	if collision_shape_3d:
		collision_shape_3d.shape.size = Vector3(width, height, depth)
	if lava_mesh:
		lava_mesh.mesh.size = Vector3(width, height, depth)


func _on_damage_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player_inside = true


func _on_damage_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player_inside = false
