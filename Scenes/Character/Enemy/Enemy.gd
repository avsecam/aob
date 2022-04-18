extends "res://Scenes/Character/Character.gd"
class_name Enemy


signal actionReadied(actionType, actionInfo, selectedTargets)

var characterInfo: Array # contains all combatant stats for targeting
var heroInfo: Array
var enemyInfo: Array
var attackChance: float = 60
var magicChance: float = 50
var techniqueChance: float = 50
#var itemChance: float = 0.3
var actionTypeChances: Array = [
	[GameData.ActionType.ATTACK, attackChance],
	[GameData.ActionType.MAGIC, magicChance],
	[GameData.ActionType.TECHNIQUE, techniqueChance]
]

var actionType: int
var subAction: String # name of specific magic, technique, or item


func _ready():
	characterStats = load("%s%s.tres" % [GameData.enemyFolderPath, name])
	characterStats.ready()
	
	characterStats.techniques = [ # [name, weight]
		["scratch", 50]
	]
	
	# clear chances if corresponding array is empty
	if characterStats.magics == []:
		actionTypeChances.erase([GameData.ActionType.MAGIC, magicChance])
	if characterStats.techniques == []:
		actionTypeChances.erase([GameData.ActionType.TECHNIQUE, techniqueChance])


# contains readying attack, magic, technique, and item
func action():
	_choose_action()
	
	var actionInfo: Dictionary = {
		"source": self
	}
	var selectedTargets: Array
	
	if actionType == GameData.ActionType.ATTACK: # Attack
		print("%s is attacking..." % characterStats.characterName)
		actionInfo["name"] = "Attack"
		actionInfo["offensive"] = true
		actionInfo["targetType"] = GameData.TargetType.SINGLE
		actionInfo["damageType"] = GameData.DamageType.PHYSICAL
		actionInfo["damage"] = characterStats.attackPhys
		selectedTargets = _choose_target(actionInfo["targetType"])
		emit_signal("actionReadied", actionType, actionInfo, selectedTargets)
		
	else:
		var actionInfoRaw: Dictionary
		match(actionType):
			GameData.ActionType.MAGIC:
				print("%s is casting %s..." % [characterStats.characterName, subAction])
				actionInfoRaw = Magic.magics[subAction.to_lower()]
				actionInfo["damage"] = characterStats.attackElem * actionInfoRaw["damageMultiplier"]
			GameData.ActionType.TECHNIQUE:
				print("%s is readying %s..." % [characterStats.characterName, subAction])
				actionInfoRaw = Technique.techniques[subAction.to_lower()]
				actionInfo["damage"] = characterStats.attackPhys * actionInfoRaw["damageMultiplier"]
		
		actionInfo["name"] = actionInfoRaw["name"]
		actionInfo["offensive"] = actionInfoRaw["offensive"]
		actionInfo["targetType"] = actionInfoRaw["targetType"]
		actionInfo["damageType"] = actionInfoRaw["damageType"]
		selectedTargets = _choose_target(actionInfo["targetType"])
		
		emit_signal("actionReadied", actionType, actionInfo, selectedTargets)


# choose what action to do
func _choose_action():
	# choose ActionType first
	actionType = actionTypeChances[_rng_weighted(actionTypeChances)][0]
	
	if actionType == GameData.ActionType.ATTACK:
		return
	
	# choose action if magic / technique
	match(actionType):
		GameData.ActionType.MAGIC:
			subAction = characterStats.magics[_rng_weighted(characterStats.magics)][0]
		GameData.ActionType.TECHNIQUE:
			subAction = characterStats.techniques[_rng_weighted(characterStats.techniques)][0]


# takes in an array of pairs: name and chance
# returns the index of the selected pair
func _rng_weighted(array: Array) -> int:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var randomNumber: int
	var weightSum: int
	var returnIndex: int # index of selected chance
	
	for pair in array:
		weightSum += pair[1]
	
	rng.randomize()
	randomNumber = rng.randi_range(0, weightSum)
	
	while returnIndex < array.size() - 1:
		if randomNumber < array[returnIndex][1]:
			break
		randomNumber -= array[returnIndex][1]
		returnIndex += 1
	return returnIndex


func _choose_target(targetType: int = GameData.TargetType.SINGLE) -> Array:
	var selectedTargets: Array
	match(targetType):
		GameData.TargetType.SINGLE:
			var targetIndex: int = randi() % heroInfo.size()
			selectedTargets.append(heroInfo[targetIndex])
		GameData.TargetType.GROUP:
			selectedTargets = heroInfo
		GameData.TargetType.ALL:
			selectedTargets = characterInfo
	
	return selectedTargets


func set_characterInfo():
	# sets the characterPOSITION only
	for character in characterInfo:
		if character[0].get_child(0).isHero: heroInfo.append(character[0])
		else: enemyInfo.append(character[0])
