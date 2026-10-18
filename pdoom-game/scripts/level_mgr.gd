extends Node2D

const SECS_PER_CHAR := 0.05
const MIN_DELAY := 0.5
const START_DELAY := 2.5

var chatFile: File
var chatContent: FileContent
@onready var folder: Folder = $DesktopUIControl/FileContainer/Folder

func _ready() -> void:
	chatFile = get_tree().get_first_node_in_group("chatFile")
	chatContent = chatFile.fileContent  # survives file/popup nodes being freed..
	
	# wait for user/player to read instructions etc files then activate chatFile
	await get_tree().create_timer(START_DELAY).timeout
	chatFile.visible = true
	folder.visible = true
	Globalz.begin_phase()

func _on_hack_pressed() -> void:
	Globalz.setup_minigame()
