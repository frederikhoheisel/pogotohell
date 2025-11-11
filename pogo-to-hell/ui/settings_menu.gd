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


func _on_fs_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_vsync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE if toggled_on else DisplayServer.VSYNC_DISABLED)


func _on_shadow_button_item_selected(index: int) -> void:
	var viewport = get_viewport()
	match index:
		0:
			viewport.positional_shadow_atlas_size = 4096
		1:
			viewport.positional_shadow_atlas_size = 4096 * 2
		2:
			viewport.positional_shadow_atlas_size = 4096 * 4


func _on_check_box_item_selected(index: int) -> void:
	var viewport = get_viewport()
	match index:
		0:
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			#viewport.msaa_2d = Viewport.MSAA_DISABLED
		1:
			viewport.msaa_3d = Viewport.MSAA_2X
			#viewport.msaa_2d = Viewport.MSAA_2X
		2:
			viewport.msaa_3d = Viewport.MSAA_4X
			#viewport.msaa_2d = Viewport.MSAA_4X
		3:
			viewport.msaa_3d = Viewport.MSAA_8X
			#viewport.msaa_2d = Viewport.MSAA_8X


func _on_master_slider_value_changed(value: float) -> void:
	%MasterVolume.text = str(value as int)
	AudioServer.set_bus_volume_db(0, linear_to_db(value * 0.1))
	AudioServer.set_bus_mute(0, value * 0.1 < 0.01)


func _on_music_slider_value_changed(value: float) -> void:
	%MusicVolume.text = str(value as int)
	AudioServer.set_bus_volume_db(1, linear_to_db(value * 0.1))
	AudioServer.set_bus_mute(1, value * 0.1 < 0.01)


func _on_sounds_slider_value_changed(value: float) -> void:
	%SoundsVolume.text = str(value as int)
	AudioServer.set_bus_volume_db(2, linear_to_db(value * 0.1))
	AudioServer.set_bus_mute(2, value * 0.1 < 0.01)
