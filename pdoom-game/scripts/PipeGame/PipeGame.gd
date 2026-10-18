class_name PipeGame
extends Node2D

signal level_won

@export var max_moves := 7
@export var terrain_set := 0
@export var terrain_id := 0
@export var level_id := 0

@onready var board: TileMapLayer = $GridNode2D/BoardTileMapLayer
@onready var level: TileMapLayer = $GridNode2D/LevelTileMapLayer
@onready var overlay = $GridNode2D/GridOverlayNode2D
@onready var hud = $HUDCanvasLayer

@export var margin := 40.0       # empty space around the grid
@export var hud_height := 80.0   # space reserved at the top for the HUD
@export var max_scale := 5.0     # don't blow tiny levels up too far

@onready var grid_node: Node2D = $GridNode2D

const SIDES := {
	Vector2i.RIGHT: TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	Vector2i.DOWN: TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	Vector2i.LEFT: TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	Vector2i.UP: TileSet.CELL_NEIGHBOR_TOP_SIDE,
}

var history: Array[Vector2i] = []   # cells the player has placed, in order
var endpoints: Array[Vector2i] = []
var won := false

var moves_left: int:
	get: return max_moves - history.size()

var original := {}   # cell -> [source_id, atlas_coords, alternative]

func _fit_grid() -> void:
	var used := board.get_used_rect()
	if used.size == Vector2i.ZERO:
		return
	# include the off-board endpoint tiles
	for c in endpoints:
		used = used.expand(c).expand(c + Vector2i.ONE)

	var tile := Vector2(board.tile_set.tile_size)
	var grid_size := Vector2(used.size) * tile
	var grid_origin := Vector2(used.position) * tile

	var top_left := Vector2(margin, margin + hud_height)
	var avail := get_viewport_rect().size - top_left - Vector2(margin, margin)

	var s := minf(avail.x / grid_size.x, avail.y / grid_size.y)
	s = minf(s, max_scale)

	grid_node.scale = Vector2(s, s)
	# centre inside the available area
	grid_node.position = top_left + (avail - grid_size * s) / 2.0 - grid_origin * s

func _ready() -> void:
	#Globalz.mg_won.connect(level_won)
	_snapshot_level()
	hud.undo_pressed.connect(undo)
	hud.reset_pressed.connect(reset)
	_find_endpoints()
	_fit_grid()
	get_viewport().size_changed.connect(_fit_grid)
	_update_win()
	_refresh_hud()

func reset_moves() -> void:
	max_moves = 3 if level_id == 0 else 7
	history.clear()
	_rebuild()
	won = false
	_update_win()
	_refresh_hud()

func _snapshot_level() -> void:
	original.clear()
	for cell in level.get_used_cells():
		original[cell] = [
			level.get_cell_source_id(cell),
			level.get_cell_atlas_coords(cell),
			level.get_cell_alternative_tile(cell),
		]

# Restore the starting level, then replay the player's remaining moves
func _rebuild() -> void:
	level.clear()
	for cell in original:
		var t = original[cell]
		level.set_cell(cell, t[0], t[1], t[2])
	for cell in history:
		level.set_cells_terrain_connect([cell], terrain_set, terrain_id)

@onready var hud_canvas_layer: CanvasLayer = $HUDCanvasLayer

func activate_hud():
	hud_canvas_layer.visible = true

func deactivate_hud():
	hud_canvas_layer.visible = false

func _process(_delta: float) -> void:
	if visible and Globalz.mg_started: activate_hud()
	var cell := level.local_to_map(level.get_local_mouse_position())
	overlay.set_hover(cell, _can_place(cell))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := level.local_to_map(level.get_local_mouse_position())
		if _can_place(cell):
			place(cell)

func _can_place(cell: Vector2i) -> bool:
	return not won and moves_left > 0 \
		and board.get_cell_source_id(cell) != -1 \
		and level.get_cell_source_id(cell) == -1

func place(cell: Vector2i) -> void:
	level.set_cells_terrain_connect([cell], terrain_set, terrain_id)
	if level.get_cell_source_id(cell) == -1:
		push_warning("Terrain placement failed: set %d, terrain %d" % [terrain_set, terrain_id])
		return
	history.append(cell)
	_update_win()
	_refresh_hud()

func undo() -> void:
	if history.is_empty():
		return
	history.pop_back()
	_rebuild()
	_update_win()
	_refresh_hud()

func reset() -> void:
	if history.is_empty():
		return
	history.clear()
	_rebuild()
	_update_win()
	_refresh_hud()

# Erase cells directly, then re-fit surviving neighbours so they reconnect properly
func _erase_cells(cells: Array) -> void:
	var neighbours := {}
	for cell in cells:
		level.erase_cell(cell)
	for cell in cells:
		for n in level.get_surrounding_cells(cell):
			if level.get_cell_source_id(n) != -1 and not cells.has(n) and not endpoints.has(n):
				neighbours[n] = true
	for n in neighbours:
		var data := level.get_cell_tile_data(n)
		if data and data.terrain >= 0:
			level.set_cells_terrain_connect([n], data.terrain_set, data.terrain)

# --- Endpoints and win detection ---

# Endpoints are the Level tiles that have no Board tile beneath them
func _find_endpoints() -> void:
	endpoints.clear()
	for cell in level.get_used_cells():
		if board.get_cell_source_id(cell) == -1:
			endpoints.append(cell)
	if endpoints.size() != 2:
		push_warning("Expected 2 endpoint tiles off the board, found %d" % endpoints.size())

# True if the tile at `cell` has a pipe opening towards `dir`
func _opens(cell: Vector2i, dir: Vector2i) -> bool:
	var data := level.get_cell_tile_data(cell)
	if data == null or data.terrain_set < 0:
		return false
	var side: TileSet.CellNeighbor = SIDES[dir]
	return data.is_valid_terrain_peering_bit(side) \
		and data.get_terrain_peering_bit(side) >= 0

func _is_connected() -> bool:
	if endpoints.size() != 2:
		return false
	var start := endpoints[0]
	var goal := endpoints[1]
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		if cell == goal:
			return true
		for dir in SIDES:
			var next: Vector2i = cell + dir
			if seen.has(next):
				continue
			if _opens(cell, dir) and _opens(next, -dir):
				seen[next] = true
				queue.append(next)
	return false

func _update_win() -> void:
	var now_won := _is_connected()
	if now_won and not won:
		level_won.emit()
		Globalz.mg_won.emit(level_id)
		print("u won game!!!!!!!")
	won = now_won

func _refresh_hud() -> void:
	hud.set_state(moves_left, not history.is_empty(), won)
