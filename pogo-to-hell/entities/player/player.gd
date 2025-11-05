class_name Player
extends CharacterBody3D


const JUMP_VELOCITY = 9.5


var look_sensitivity: float = 0.005

var ground_speed: float = 3.0
var ground_accel: float = 14.0
var ground_decel: float = 10.0
var ground_friction: float = 3.0

var air_accel: float = 800.0
var air_move_speed: float = 500.0
var air_speed_cap: float = 1.5

var wall_normal: Vector3 = Vector3.ZERO
var wall_pos: Vector3 = Vector3.ZERO
var max_wall_dist: float = 0.2
var on_wall: bool = false
var wall_tween: Tween

var jump_strength: float = 0.0
var jump_cooldown: float = 0.5 # damit man nicht an Wänden kleben bleibt nachdem man gesprungen ist
var time_since_last_jump: float = 0.0
var jump_buffered: bool = false
var jump_buffer_time: float = 0.2
var jump_buffer_timer: float = 0.0

var wish_dir: Vector3 = Vector3.ZERO


@onready var head: Node3D = $Head
@onready var pogo: Node3D = $pogo


func _handle_jump(delta: float) -> void:
	time_since_last_jump += delta
	if Input.is_action_pressed("jump"):
		jump_strength += delta
		jump_strength = clamp(jump_strength, 0.0, 1.0)
	
	if Input.is_action_just_released("jump"):
		jump_buffered = true
		jump_buffer_timer = 0.0
	
	if jump_buffered:
		if is_on_floor() or on_wall:
			self.velocity = Vector3(
					self.velocity.x + wall_normal.x * JUMP_VELOCITY, 
					JUMP_VELOCITY, 
					self.velocity.z + wall_normal.z * JUMP_VELOCITY
			) * jump_strength
			
			on_wall = false
			wall_normal = Vector3.ZERO
			jump_buffered = false
			jump_strength = 0.0
			time_since_last_jump = 0.0
		
		if jump_buffer_timer > jump_buffer_time:
			jump_buffered = false
			jump_strength = 0.0
		
		jump_buffer_timer += delta


func _handle_ground_physics(delta) -> void:
	var cur_speed_in_wish_dir: float = self.velocity.dot(wish_dir)
	var add_speed_till_cap: float = ground_speed - cur_speed_in_wish_dir
	
	if add_speed_till_cap > 0.0:
		var accel_speed: float = ground_accel * ground_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	var control: float = max(self.velocity.length(), ground_decel)
	var drop: float = control * ground_friction * delta
	var new_speed: float = max(self.velocity.length() - drop, 0.0)
	
	if self.velocity.length() > 0.0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed


func _handle_air_physics(delta: float) -> void:
	velocity += get_gravity() * delta
	
	var cur_speed_in_wish_dir: float = self.velocity.dot(wish_dir)
	var capped_speed: float = min((air_move_speed * wish_dir).length(), air_speed_cap)
	var add_speed_till_cap: float = capped_speed - cur_speed_in_wish_dir
	
	if add_speed_till_cap > 0.0:
		var accel_speed: float = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	if on_wall and time_since_last_jump > jump_cooldown:
		# damit man an Wänden nicht ungehindert in eine Richtung slidet
		self.velocity.x = move_toward(self.velocity.x, 0.0, delta)
		self.velocity.z = move_toward(self.velocity.z, 0.0, delta)
		
		# ich habe nicht den blassesten Schimmer warum das nicht mit Vector clamp funktioniert :(
		#self.velocity.clamp(
		#		Vector3(jump_strength - 1.0, jump_strength - 1.0, jump_strength - 1.0), 
		#		Vector3(1.0 - jump_strength, 1.0 - jump_strength, 1.0 - jump_strength)
		#)
		
		self.velocity.x = clampf(self.velocity.x, jump_strength - 1.0, 1.0 - jump_strength)
		self.velocity.y = clampf(self.velocity.y, jump_strength - 1.5, 1.0 - jump_strength)
		self.velocity.z = clampf(self.velocity.z, jump_strength - 1.0, 1.0 - jump_strength)
	
	if is_on_wall():
		on_wall = true
		wall_normal = get_wall_normal().normalized() # normalized just in case idk
		wall_pos = self.global_position


func _rotate_head_and_pogo(delta: float) -> void:
	if on_wall:
		# rotate head
		head.rotation.z = move_toward(head.rotation.z, (PI / 8.0) * (self.transform.basis * Vector3.LEFT).dot(wall_normal), delta * 3.0)
		
		# rotate pogo
		var yaw: float = atan2(wall_normal.x, wall_normal.z) + PI
		var yaw_basis: Basis = Basis(Vector3.UP, yaw)
		
		var n_local: Vector3 = yaw_basis.inverse() * wall_normal
		
		pogo.global_rotation = Vector3(
				(PI / 8.0) * Vector3.BACK.dot(n_local),
				yaw,
				(PI / 8.0) * Vector3.LEFT.dot(n_local)
			)
		
		#pogo.global_rotation.z = move_toward(pogo.global_rotation.z, (PI / 8.0) * Vector3.LEFT.dot(wall_normal), delta * 3.0)
		#pogo.global_rotation.x = move_toward(pogo.global_rotation.x, (PI / 8.0) * Vector3.BACK.dot(wall_normal), delta * 3.0)
	else:
		# derotate head and pogo
		head.rotation.z = move_toward(head.rotation.z, 0.0, delta)
		pogo.global_rotation.z = move_toward(pogo.global_rotation.z, 0.0, delta)
		pogo.global_rotation.x = move_toward(pogo.global_rotation.x, 0.0, delta)
		pogo.rotation.y = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			self.rotate_y(-event.relative.x * look_sensitivity)
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta: float) -> void:
	# Handle jump and wall jump (je aufgeladener der Sprung ist, desto mehr klingy ist man an der wand)
	_handle_jump(delta)
	
	_rotate_head_and_pogo(delta)
	
	# move down camera when charging jump
	%Camera3D.position.y = -jump_strength * 0.2
	
	# turn pogo red and scale a bit
	$pogo/MeshInstance3D.mesh.material.albedo_color = Color(1.0, 1.0 - jump_strength, 1.0 - jump_strength)
	pogo.scale.y = 1.0 - jump_strength * 0.5
	
	# NEIN
	#var fov: float = 12.0 * self.velocity.length()
	#%Camera3D.fov = clampf(fov, 70.0, 120.0)
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward").normalized()
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	# not on wall anymore
	if on_wall and abs((self.global_position - wall_pos).dot(wall_normal)) > max_wall_dist or is_on_floor():
		on_wall = false
		wall_normal = Vector3.ZERO
	
	if is_on_floor():
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	move_and_slide()
