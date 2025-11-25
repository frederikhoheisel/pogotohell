extends CanvasLayer


signal intro_finished


var stage2: bool = false


@onready var texture_rect: TextureRect = $TextureRect
@onready var center_container: CenterContainer = $CenterContainer
@onready var animated_sprite_2d: AnimatedSprite2D = $CenterContainer/Control/AnimatedSprite2D
@onready var texture_rect_2: TextureRect = $TextureRect2


func start() -> void:
	animated_sprite_2d.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
	center_container.hide()
	texture_rect.show()
	stage2 = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if stage2:
			intro_finished.emit()
			texture_rect.hide()
			texture_rect_2.hide()
		else:
			center_container.hide()
			texture_rect.show()
			stage2 = true
