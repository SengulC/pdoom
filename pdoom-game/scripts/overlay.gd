extends ColorRect

func _ready() -> void:
	$BudgetLabel.text = "%s" %Globalz.currBudget
	Globalz.budget_reduced.connect(updateBudgetLabel)
	Globalz.inner_dialog.connect(updateInnerLabel)
	#Globalz.hide_inner.connect(hideInnerLabel)
	
func updateBudgetLabel(amount: int):
	$BudgetLabel.text = "%s" %amount

func updateInnerLabel(words: String):
	print("in updateInnerLabel")
	$InnerLabel.visible = true
	$InnerLabel.text = words
	await get_tree().create_timer(5.0).timeout
	hideInnerLabel()

func hideInnerLabel():
	print("in hideInnerLabel")
	$InnerLabel.visible = false
