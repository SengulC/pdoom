extends Node2D

const SECS_PER_CHAR := 0.5
const MIN_DELAY := 0.8

var chatFile: File

func _ready() -> void:
	chatFile = get_tree().get_first_node_in_group("chatFile")
	begin_phase_01()

func begin_phase_01() -> void:
	for dict in Phases.phase01:
		for speaker in dict:
			var line: String = dict[speaker]
			chatFile.fileContent.append("%s: %s\n" % [speaker, line])
			await get_tree().create_timer(maxf(MIN_DELAY, line.length() * SECS_PER_CHAR)).timeout
			#await get_tree().create_timer(MIN_DELAY).timeout
