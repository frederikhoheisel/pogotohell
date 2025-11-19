extends Node

@export
var camera:Camera3D
@export
var player:Player
@export
var max_dash_distance: float = 10.0
@export
var dash_speed: float = 3.0

var dash_dir:Vector3
var dash_start: Vector3
var is_dashing: bool
#	var player: Player
var hit_obstacle: bool = false

func _ready() -> void:
	#player = $"."
	pass

func _process(delta: float) -> void:
	if is_dashing:
		# on_floor/on_wall tests not working
		var collisions = player.get_slide_collision(player.get_slide_collision_count() -1)
		for collision_idx in range(player.get_slide_collision_count()):
			if "CSGBox3D CSGCylinder3D StaticBody3D CSGCombiner3D CSGPolygon3D".contains(player.get_slide_collision(collision_idx).get_collider().get_class()):
				hit_obstacle = true
		if !hit_obstacle && (dash_start - player.global_position).length() < max_dash_distance:
			# check if player is touching wall/floor
			# if not, move along dash_dir
			player.position += 0.1* dash_dir * dash_speed
		else:
			is_dashing = false
			hit_obstacle = false
			player.velocity += dash_dir.normalized() * 3
	
	
	
	pass

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
	
	dash_start = player.global_position
	# move in view direction
	
	# disable hitbox
	# toggle dmg collider along dash path
	# animation
	pass
