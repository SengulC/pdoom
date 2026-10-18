extends Node2D

@onready var level: TileMapLayer = $"../LevelTileMapLayer"

var hover_cell := Vector2i.ZERO
var valid := false

func set_hover(cell: Vector2i, is_valid: bool) -> void:
	if cell == hover_cell and is_valid == valid:
		return
	hover_cell = cell
	valid = is_valid
	queue_redraw()

func _draw() -> void:
	var size := Vector2(level.tile_set.tile_size)
	var center := level.map_to_local(hover_cell)
	var rect := Rect2(center - size / 2.0, size)
	var color := Color(1, 1, 1, 0.35) if valid else Color(1, 0, 0, 0.25)
	draw_rect(rect, color)
	
