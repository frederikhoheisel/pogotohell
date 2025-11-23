extends Node

@export
var camera:Camera3D
@export
var player:Player
@export
var max_dash_time: float = 0.5
@export
var dash_speed: float = 5.0

var dash_dir:Vector3
var is_dashing: bool
#	var player: Player
var hit_obstacle: bool = false
var dash_timer: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_process_dash(delta)

func _process_dash(delta:float) -> void:
	if is_dashing:
		# check for collision with environment for snappy landing
		for collision_idx in range(player.get_slide_collision_count()):
			if "CSGBox3D CSGCylinder3D StaticBody3D CSGCombiner3D CSGPolygon3D".contains(player.get_slide_collision(collision_idx).get_collider().get_class()):
				hit_obstacle = true
		if dash_timer < max_dash_time:
			dash_timer += delta
			player.velocity = dash_dir * dash_speed * delta * 1000
		else:
			#finished dash
			is_dashing = false
			hit_obstacle = false
			player.velocity = dash_dir.normalized() * 3
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"):
		dash()

func light_attack():
	pass
	
func dash() -> void:
	# clear velocity
	player.velocity = Vector3.ZERO
	is_dashing = true
	dash_dir = -camera.get_global_transform().basis.z
	dash_timer = 0.0
	# move in view direction
	
	# disable hitbox
	player.collision_layer 
	# toggle dmg collider along dash path
	# animation
	pass
