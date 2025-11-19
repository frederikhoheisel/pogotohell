@tool
extends "res://addons/curvemesh3d/curvemesh3d.gd"


var is_grappling: bool = false
var start_point: Vector3
var dir: Vector3
var end_point: Vector3


func _process(_delta: float) -> void:
	if is_grappling:
		self.show()
		self.curve.set_point_position(0, start_point)
		self.curve.set_point_out(0, dir)
		self.curve.set_point_position(1, end_point)
	else:
		self.hide()
