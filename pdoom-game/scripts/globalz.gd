extends Node

enum fileStates {IDLE, DRAGGING, DROPPED}
var filesInFolder := []

func add_file(file: File):
	filesInFolder.append(file.duplicate())
	print("added file to folder", filesInFolder)
