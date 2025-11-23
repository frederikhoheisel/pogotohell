extends CharacterBody3D


var direction: Vector3  = Vector3.ZERO
var speed: float = 5.0
var lifetime: float = 10.0
var time: float = 0.0


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	self.look_at(self.global_position + direction * 10.0)
	self.global_position += direction * speed * delta
	
	time += delta
	if time > lifetime:
		self.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if time < 0.1:
		return
	if body.has_method("take_damage"):
		body.take_damage(1)
		self.queue_free()


func take_damage(_amount: int) -> void:
	self.queue_free()
