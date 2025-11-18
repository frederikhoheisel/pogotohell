extends Node

@export
var camera:Camera3D
@export
var player:Player
@export
var max_dash_distance: float

var dash_dir:Vector3
var dash_start: Vector3
var is_dashing: bool
#	var player: Player

func _ready() -> void:
	#player = $"."
	pass

func _process(delta: float) -> void:
	if is_dashing:
		# on_floor/on_wall tests not working
		if (player.global_position - dash_start).length() < max_dash_distance && !(player.on_floor || player.on_wall):
			# check if player is touching wall/floor
			player.position += 0.1 * dash_dir#change to view direction
			# if not, move along dash_dir
		else:
			is_dashing = false
	
	
	
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
	
	dash_start = player.position
	# move in view direction
	
	# disable hitbox
	# toggle dmg collider along dash path
	# animation
	pass
