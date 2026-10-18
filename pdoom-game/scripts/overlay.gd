extends ColorRect

func _ready() -> void:
	$Label.text = "%s" %Globalz.currBudget
	Globalz.budget_reduced.connect(updateBudgetLabel)
	print("connected signal")
	
func updateBudgetLabel(amount: int):
	print("updating label")
	$Label.text = "%s" %amount
