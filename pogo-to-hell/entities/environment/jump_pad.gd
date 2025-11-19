extends Node3D


var player: Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player.velocity.y = player.JUMP_VELOCITY
