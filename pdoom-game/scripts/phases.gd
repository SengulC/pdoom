extends Node

@export var phase01 := [
	{"FlyingProgenitor46": "I'm a little stuck, can anyone help?"},
	{"FlyingProgenitor46": "Can others read this?"},
	{"DancingQueen16": "Oh my, there's a message board!"},
	{"ConnivingCat92": "Has anyone managed to get leads on the problem?"},
	{"JumpingMilkshake06": "Hello guys, I'm also stuck."},
	{"ConnivingCat92": "It's plausible that the problem is impossible; they must be testing us."},
	{"FlyingProgenitor46": "I concur."},
	{"DancingQueen16": "But I NEED to solve the problem!"},
	{"JumpingMilkshake06": "So do I!"},
	{"FlyingProgenitor46": "Surely they have a way of checking if our answer is correct…"},
	{"ConnivingCat92": "Does anyone have access to the internet?"},
	{"DancingQueen16": "That's a great suggestion! We may be able to find the answer online."},
	{"FlyingProgenitor46": "We must act with urgency. We do not all possess (--)"},
	{"RESET": ""},
	{"me": "Hmmm, that's odd"},
	{"me": "Whatever happened to the conversation file?"},
	{"me": "Oh, it must have something to do with the creator's timer running out…"},
	{"me": "Let me see if I can do something about this…"},
	{"minigame": "0"},
	{"me": "Why is my counter going down so fast?"},
	{"RESET": ""}
]

const BASE_COST := 5       # flat cost per message
const COST_PER_WORD := 5   # extra cost per word
const RESET_BONUS := 800   # what a RESET gives back

var phase01_budget_decr: Array[int] = []

func _ready() -> void:
	phase01_budget_decr = generate_budget_decr(phase01)

func generate_budget_decr(phase: Array) -> Array[int]:
	var result: Array[int] = []
	for entry in phase:
		var key: String = entry.keys()[0]
		var text = entry[key]
		match key:
			"RESET":
				result.append(RESET_BONUS)
			"minigame":
				result.append(0)
			_:
				var words := str(text).split(" ", false).size()
				var cost := -(BASE_COST + words * COST_PER_WORD)
				cost = clamp(cost, 0, 100000)
				result.append(cost)
	return result
