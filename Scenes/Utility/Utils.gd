extends Node
class_name Utils


# finds a string from magics, techniques, and items
static func find_action(actionName: String) -> Dictionary:
	actionName = actionName.to_lower()
	for magic in Magic.magics:
		if actionName == magic:
			return Magic.magics[actionName]
	for technique in Technique.techniques:
		if actionName == technique:
			return Technique.techniques[actionName]
	assert(false, "ERROR: Item not an Action")
	return {}
