extends Node3D


var fire_delay: float = 0.5
var fire_time: float = 0.0
var camera_tween: Tween
var camera_shake_amount = PI/12.0


@onready var hit_ray_cast: RayCast3D = %HitRayCast
@onready var view_model: Node3D = %ViewModel
@onready var camera_3d: Camera3D = %Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	fire_time += delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		if fire_time < fire_delay:
			return
		shake_camera()
		view_model.play_fire_anim()
		fire_time = 0.0
	
	if event.is_action_pressed("pull_out"):
		view_model.play_pull_out_anim()


func shake_camera() -> void:
	if camera_tween:
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	
	camera_3d.rotation.x = camera_3d.rotation.x + camera_shake_amount
	camera_tween.tween_property(camera_3d, "rotation", Vector3(camera_3d.rotation.x - camera_shake_amount, camera_3d.rotation.y, camera_3d.rotation.z), 0.4)
