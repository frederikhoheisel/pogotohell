class_name Broski
extends CharacterBody3D


@export var health: int = 3
@export var move_speed: float = 4.0
@export var steering_strength: float = 2.0
@export var rotation_speed: float = 4.0
@export var desired_distance_player: float = 5.0
@export var distance_tolerance: float = 2.0
@export var origin_distance: float = 10.0

@export var loose_player_interval: float = 2.0


var shoot_interval: float = 2.0
var dir_change_interval: float = 2.0
var origin_pos: Vector3
var player_spotted: bool = false
var player_inside: bool = false
var player: Player
var circle_direction: Vector3 = Vector3.ZERO
var time_change_dir: float = 0.0
var time_loose_player: float = 0.0
var time_shoot: float = 0.0
var pieces: PackedScene = preload("res://entities/enemies/broski/broski_pieces.tscn")
var eye_projectile: PackedScene = preload("res://entities/enemies/broski/eye_projectile.tscn")
var blood_expl_particles:  PackedScene = preload("res://entities/effects/blood_expl_particles.tscn")


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var debug_label: Label3D = $DebugLabel
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer


func take_damage(amount: int = 1) -> void:
	health -= amount
	if health <= 0:
		get_tree().get_first_node_in_group("Score").increase_combo(true)
		$Bleeding.stop_bleeding()
		#get_tree().get_first_node_in_group("SmokeManager").place_smoke(self.global_position + Vector3(0.0, 1.0, 0.0), true, 2.0)
		get_tree().get_first_node_in_group("SmokeManager").place_blood_expl(self.global_position)
		audio_stream_player.stream = AudioStreamWAV.load_from_file("res://assets/sounds/enemy_down1.wav")
		audio_stream_player.volume_db = -6.0
		audio_stream_player.play()
		var pieces_scene: Node3D = pieces.instantiate()
		self.get_parent().add_child(pieces_scene)
		pieces_scene.transform = self.transform
		self.hide()
		await get_tree().create_timer(1.0).timeout
		self.queue_free()
		return
	$Bleeding.start_bleeding()
	get_tree().get_first_node_in_group("Score").increase_combo(false)

func _ready() -> void:
	animation_player.play("idle")
	player = get_tree().get_first_node_in_group("Player")
	origin_pos = self.global_position


func _process(_delta: float) -> void:
	debug_label.text = str(health)


func _physics_process(delta: float) -> void:
	if not player_inside:
		time_loose_player += delta
	
	if time_loose_player > loose_player_interval:
		player_spotted = false
	
	# change direction sometimes
	time_change_dir += delta
	# öfter changen wenn player_spottet
	if time_change_dir > (dir_change_interval if player_spotted else dir_change_interval * 2.0):
		dir_change_interval = randf_range(1.5, 4.0) # randomize a bit
		
		circle_direction = _random_direction()
		time_change_dir = 0.0
	
	var desired_velocity: Vector3
	
	if player_spotted:
		var to_player: Vector3 = player.global_transform.origin - self.global_transform.origin
		var distance: float = to_player.length()
		var dir_to_player: Vector3 = to_player.normalized()
		
		_rotate(dir_to_player, delta)
		
		var keep_distance_dir: Vector3 = Vector3.ZERO
		
		if distance > desired_distance_player + distance_tolerance:
			keep_distance_dir = dir_to_player
		elif distance < desired_distance_player - distance_tolerance:
			keep_distance_dir = -dir_to_player
		
		desired_velocity = (circle_direction + keep_distance_dir).normalized() * move_speed
		
		_shoot_projectile(dir_to_player, delta)
	else:
		if self.global_position.distance_to(origin_pos) > origin_distance:
			circle_direction = origin_pos - self.global_position
		
		desired_velocity = circle_direction.normalized() * move_speed * 0.2
		
		_rotate(desired_velocity, delta)
	
	self.velocity = self.velocity.lerp(desired_velocity, steering_strength * delta)
	
	move_and_slide()


func _shoot_projectile(dir_to_player: Vector3, delta: float) -> void:
	time_shoot += delta
	if time_shoot > shoot_interval:
		audio_stream_player.stream = AudioStreamWAV.load_from_file("res://assets/sounds/enemy_shot1.wav")
		audio_stream_player.play()
		var projectile: Node3D = eye_projectile.instantiate()
		get_tree().get_first_node_in_group("ProjectileContainer").add_child(projectile)
		projectile.direction = dir_to_player
		projectile.global_position = self.global_position + Vector3(0.0, 1.0, 0.0)
		
		time_shoot = 0.0
		shoot_interval = randf_range(1.5, 4.0)


func _random_direction() -> Vector3:
	var angle = randf() * TAU
	return Vector3(cos(angle), randf_range(-0.1, 0.1), sin(angle)).normalized()


func _rotate(dir: Vector3, delta: float):
	var direction: Vector3 = (Vector3(dir.x, 0.0, dir.z)).normalized()
	
	if direction.is_zero_approx():
		return
	
	self.global_transform.basis = self.global_transform.basis.slerp(Basis.looking_at(direction, Vector3.UP), delta * rotation_speed)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player_inside = true
		player_spotted = true
		time_loose_player = 0.0


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player_inside = false
