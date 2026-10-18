extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globalz.overlay.find_child("BudgetLabel").visible = false
	Globalz.overlay.find_child("TextureRect").visible = false
	create_tween().tween_property($ColorRect/ColorRect2, "modulate:a", 0.0, 1.0)
	
	AudioManager.change_music("intro")
	#Globalz.pulse_params([5.0, 1.0])   # glitch_rate -> 5, glitch_intensity -> 1, then back

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
