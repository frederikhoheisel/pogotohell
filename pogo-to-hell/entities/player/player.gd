class_name Player
extends CharacterBody3D


const JUMP_VELOCITY = 9.5


var look_sensitivity: float = 0.005

var ground_speed: float = 7.0
var ground_accel: float = 14.0
var ground_decel: float = 10.0
var ground_friction: float = 3.0

var air_accel: float = 800.0
var air_move_speed: float = 500.0

var wall_normal: Vector3 = Vector3.ZERO
var on_floor: bool = false
var on_wall: bool = false
var jump_strength: float = 0.0

var wish_dir: Vector3 = Vector3.ZERO
var cam_aligned_wish_dir: Vector3 = Vector3.ZERO


@onready var head: Node3D = $Head


func _handle_jump(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		jump_strength += delta
		jump_strength = clamp(jump_strength, 0.0, 1.0)
	
	if Input.is_action_just_released("jump"):
		if is_on_floor() or on_wall:
			self.velocity = Vector3(
					self.velocity.x + wall_normal.x * JUMP_VELOCITY, 
					JUMP_VELOCITY, 
					self.velocity.z + wall_normal.z * JUMP_VELOCITY
			) * jump_strength
			
			on_wall = false
			wall_normal = Vector3.ZERO
		jump_strength = 0.0


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
	var cur_speed_in_wish_dir: float = self.velocity.dot(wish_dir)
	var capped_speed: float = min((air_move_speed * wish_dir).length(), 0.85)
	var add_speed_till_cap: float = capped_speed - cur_speed_in_wish_dir
	
	if add_speed_till_cap > 0.0:
		var accel_speed: float = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir
	
	if is_on_wall():
		on_wall = true
		wall_normal = get_wall_normal()


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
	# Add the gravity.
	if on_wall:
		velocity = clamp(velocity, Vector3(jump_strength - 1.0, jump_strength - 1.0, jump_strength - 1.0), 
			Vector3(1.0 - jump_strength, 1.0 - jump_strength, 1.0 - jump_strength))
		#velocity.y = clamp(velocity.y, -1.0, 0.1)
		head.rotation.z = wall_normal.dot(%Camera3D.transform.basis * Vector3.FORWARD) * 0.1
		velocity += get_gravity() * delta * (1.0 - jump_strength)
	elif not is_on_floor():
		head.rotation.z = 0.0
		velocity += get_gravity() * delta
	else:
		head.rotation.z = 0.0

	# Handle jump and wall jump (je aufgeladener der Sprung ist, desto mehr klingy ist man an der wand)
	_handle_jump(delta)
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward").normalized()
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	if wish_dir:
		on_wall = false
		wall_normal = Vector3.ZERO
	
	if is_on_floor():
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	move_and_slide()
