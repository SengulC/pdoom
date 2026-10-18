class_name FileContent
extends Resource

signal changed_content(new_content: String)

@export var content : String

func append(new_msg : String):
	content += new_msg
	changed_content.emit(content)
