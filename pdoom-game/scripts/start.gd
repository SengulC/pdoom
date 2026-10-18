extends Node2D
const LEVEL = preload("uid://dsgejvhabk7xe")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_tween().tween_property($ColorRect/ColorRect2, "modulate:a", 0.0, 1.0)
	AudioManager.play_music("intro")
	Globalz.overlay.find_child("BudgetLabel").visible = false
	Globalz.overlay.find_child("TextureRect").visible = false


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(LEVEL)
