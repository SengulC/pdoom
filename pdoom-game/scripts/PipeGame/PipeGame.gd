extends Node2D

signal level_won

@export var max_moves := 10
@export var terrain_set := 0
@export var terrain_id := 0

@onready var board: TileMapLayer = $GridNode2D/BoardTileMapLayer
@onready var level: TileMapLayer = $GridNode2D/LevelTileMapLayer
@onready var overlay = $GridNode2D/GridOverlayNode2D
@onready var hud = $HUDCanvasLayer

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

func _ready() -> void:
	_snapshot_level()
	hud.undo_pressed.connect(undo)
	hud.reset_pressed.connect(reset)
	_find_endpoints()
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

func _process(_delta: float) -> void:
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
	won = now_won

func _refresh_hud() -> void:
	hud.set_state(moves_left, not history.is_empty(), won)
