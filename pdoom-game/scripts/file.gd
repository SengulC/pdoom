extends TextureButton

var mouseInArea := false
enum fileStates {IDLE, DRAGGING, DROPPED}
var currState := fileStates.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("mouse_entered", _on_file_mouse_entered)
	self.connect("mouse_exited", _on_file_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if currState == fileStates.DRAGGING:
		_drag()
	if currState == fileStates.DROPPED:
		_drop()
	#print(Input.get_last_mouse_velocity())

func _drag():
	print("dragging")
	if Input.get_last_mouse_velocity().abs() > Vector2.ZERO:
		var currentMousePos = get_global_mouse_position()
		var offsetVector = Vector2((size.x*scale.x)/pivot_offset_ratio.x, 0)
		#var offsetVector = Vector2(-250,0)
		var finalFilePos = currentMousePos - offsetVector
		position = finalFilePos
		print(position, currentMousePos)

func _drop():
	print("dropping")
	#position = get_global_mouse_position()
	currState = fileStates.IDLE

func _input(event):
	# if user's mouse is in area of file, has clicked, and the mouse is in motion
	if event.is_action_pressed("lmb_click") and mouseInArea:
		currState = fileStates.DRAGGING
	if event.is_action_released("lmb_click"):
		currState = fileStates.DROPPED
	pass

func _on_file_mouse_entered() -> void:
	mouseInArea = true
	#print(mouseInArea)

func _on_file_mouse_exited() -> void:
	mouseInArea = false
	#print(mouseInArea)
