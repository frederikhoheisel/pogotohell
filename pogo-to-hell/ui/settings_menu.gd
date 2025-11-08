extends CanvasLayer


signal settings_disabled(to: bool)


var crosshair_material: ShaderMaterial



func _ready() -> void:
	crosshair_material = %Crosshair.material
	%ColorPicker.color = crosshair_material.get_shader_parameter("col")
	%CheckBox.button_pressed = crosshair_material.get_shader_parameter("use_inv_screen_color")
	%LenghtHSlider.value = crosshair_material.get_shader_parameter("size") * 100.0
	%ThickHSlider.value = crosshair_material.get_shader_parameter("thick") * 200.0
	%GapHSlider.value = crosshair_material.get_shader_parameter("hole") * 200
	%HaloHSlider.value = crosshair_material.get_shader_parameter("halo_thickness") * 1000.0
	
	%SensitivityHSlider.value = get_parent().player.look_sensitivity * 10000.0


func _on_inverse_color_toggled(toggled_on: bool) -> void:
	crosshair_material.set_shader_parameter("use_inv_screen_color", toggled_on)
	


func _on_color_picker_color_changed(color: Color) -> void:
	crosshair_material.set_shader_parameter("col", color)


func _on_lenght_h_slider_value_changed(value: float) -> void:
	crosshair_material.set_shader_parameter("size", value / 100.0)
	%LengthLabel.text = str(value as int)


func _on_button_pressed() -> void:
	settings_disabled.emit(false)


func _on_thick_h_slider_value_changed(value: float) -> void:
	crosshair_material.set_shader_parameter("thick", value / 200.0)
	%ThickLabel.text = str(value as int)


func _on_gap_h_slider_value_changed(value: float) -> void:
	crosshair_material.set_shader_parameter("hole", value / 200.0)
	%GapLabel.text = str(value as int)


func _on_halo_h_slider_value_changed(value: float) -> void:
	crosshair_material.set_shader_parameter("halo_thickness", value / 1000.0)
	%HaloLabel.text = str(value as int)


func _on_sensitivity_h_slider_value_changed(value: float) -> void:
	%SensitivityLabel.text = str(value as int)
	get_parent().player.look_sensitivity = value * 0.0001
