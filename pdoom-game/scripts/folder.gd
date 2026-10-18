class_name Folder extends TextureRect
@onready var area_2d: Area2D = $Area2D
@export var persistent := false # TODO

var grab_offset := Vector2.ZERO
var press_pos := Vector2.ZERO
var mouseInArea := false

func _ready() -> void:
	area_2d.connect("mouse_entered", _on_mouse_entered)
	area_2d.connect("mouse_exited", _on_mouse_exited)
	print("setup")

#func _process(delta: float) -> void:
	#print(mouseInArea)

## FOR DETECTING IF FILE IS ABOUT TO BE DROPPED
func _on_folder_area_entered(area: Area2D) -> void:
	print("file hovering over folder %s" %area.get_parent().name)
	var file : File = area.get_parent()
	file.fileOverFolder = true

func _on_folder_area_exited(area: Area2D) -> void:
	var file : File = area.get_parent()
	file.fileOverFolder = false

## FOR DETECTING MOUSE HOVER & DOUBLE CLICK
func _on_mouse_entered() -> void:
	mouseInArea = true
	#print("mouseInArea: ", mouseInArea)
	
func _on_mouse_exited() -> void:
	mouseInArea = false
	#print("mouseInArea: ", mouseInArea)

func _input(event: InputEvent):
	# double click
	if event.is_action_pressed("lmb_click") and mouseInArea:
		press_pos = get_global_mouse_position()
		grab_offset = press_pos - global_position

		if event is InputEventMouseButton and event.double_click:
			Globalz.open_folder()
