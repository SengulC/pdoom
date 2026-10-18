extends ColorRect

func _ready() -> void:
	$HSlider.value = AudioManager.music_vol

func _on_h_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume($HSlider.value)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible
