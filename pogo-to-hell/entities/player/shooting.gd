extends Node3D


var fire_delay: float = 0.3
var fire_time: float = 0.0
var camera_tween: Tween
var camera_shake_amount = PI/24.0
var camera_shake_duration: float = 0.4
var decal: PackedScene = preload("res://entities/effects/decal.tscn")
var grapple_point: Vector3
var player: Player


@onready var hit_ray_cast: RayCast3D = %HitRayCast
@onready var view_model: Node3D = %ViewModel
@onready var camera_3d: Camera3D = %Camera3D
@onready var head: Node3D = $"../Head"


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


func _process(delta: float) -> void:
	fire_time += delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if fire_time < fire_delay:
			return
		fire_time = 0.0
		shoot_gun()
	
	if event.is_action_pressed("grapple"):
		grapple()
	
	if event.is_action_pressed("pull_out"):
		view_model.play_pull_out_anim()


func _shake_camera() -> void:
	if camera_tween:
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel(false)
	camera_tween.tween_property(head, "rotation", Vector3(head.rotation.x + camera_shake_amount, head.rotation.y, head.rotation.z), camera_shake_duration * 0.2)
	camera_tween.tween_property(head, "rotation", Vector3(head.rotation.x, head.rotation.y, head.rotation.z), camera_shake_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func shoot_gun() -> void:
	_shake_camera()
	view_model.play_fire_anim()
	
	hit_ray_cast.force_raycast_update()
	if hit_ray_cast.is_colliding():
		var collider = hit_ray_cast.get_collider()
		
		var collision_point: Vector3 = hit_ray_cast.get_collision_point()
		var collision_normal: Vector3 = hit_ray_cast.get_collision_normal()
		
		get_tree().get_first_node_in_group("DecalManager").place_decal(collision_point, collision_normal)
		
		if collider.has_method("take_damage"):
			collider.take_damage(1)
		
		if collider is SoftBody3D:
			collider.apply_central_impulse(collision_normal * -10.0)


func grapple() -> void:
	hit_ray_cast.force_raycast_update()
	
	if hit_ray_cast.is_colliding():
		var collider = hit_ray_cast.get_collider()
		
		if collider is not StaticBody3D and\
				collider is not CSGCombiner3D and\
				collider is not CSGBox3D and\
				collider is not CSGCylinder3D and\
				collider is not CSGPolygon3D and\
				collider is not CSGSphere3D and\
				collider is not CSGTorus3D and\
				collider is not CSGMesh3D:
			return
		
		var collision_point: Vector3 = hit_ray_cast.get_collision_point()
		
		player.grapple_point = collision_point
		player.is_grappling = true
