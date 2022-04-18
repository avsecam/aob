extends Spatial
class_name CombatCharacter


signal attackReadied(info)
signal magicReadied(info)
signal techniqueReadied(info)
signal damaged()
signal downed()

onready var combatInfo: Control = $Billboard/Viewport/CombatInfo
onready var characterName: Label = combatInfo.get_node("Container/VBoxContainer/Label")
onready var healthBar: ProgressBar = combatInfo.get_node("Container/VBoxContainer/Health")
onready var resourceBar: ProgressBar = combatInfo.get_node("Container/VBoxContainer/Resource")

var character: Spatial # Hero or Enemy node
var characterStats: CharacterStats
var isHero: bool = false
var isSelected: bool = false


func _ready():
	characterStats = character.characterStats
	character = get_child(get_children().size() - 1)
	
	# set the combat info
	characterName.text = characterStats.characterName
	healthBar.max_value = characterStats.maxHealth
	resourceBar.max_value = characterStats.maxResource
	_update_health_bar()
	_update_resource_bar()
	
	if !isHero:
		character.connect("actionReadied", self, "_on_enemy_readied")

func _physics_process(_delta):
	if isSelected:
		combatInfo.modulate = Color(1, 1, 0, 1)
		character.sprite.modulate = Color(1, 0, 1, 1)
	else:
		combatInfo.modulate = Color(1, 1, 1, 1)
		character.sprite.modulate = Color(1, 1, 1, 1)


func _update_health_bar():
	healthBar.value = characterStats.currentHealth
	healthBar.get_node("Label").text = "%d / %d" % [characterStats.currentHealth, characterStats.maxHealth]
func _update_resource_bar():
	resourceBar.value = characterStats.currentResource
	resourceBar.get_node("Label").text = "%d / %d" % [characterStats.currentResource, characterStats.maxResource]


# contains readying attack, magic, technique, and item
func action(action: Button = Button.new(), category: String = ""):
	if !isHero:
		character.action()
		return
	
	var actionInfo: Dictionary
	
	if action.text.to_lower() == "attack": # Attack
		print("%s is attacking..." % characterStats.characterName)
		actionInfo["name"] = "Attack"
		actionInfo["source"] = character
		actionInfo["offensive"] = true
		actionInfo["targetType"] = GameData.TargetType.SINGLE
		actionInfo["damageType"] = GameData.DamageType.PHYSICAL
		actionInfo["damage"] = characterStats.attackPhys
		emit_signal("attackReadied", actionInfo)
		
	else:
		match(category.to_lower()):
			"magic":
				print("%s is casting %s..." % [characterStats.characterName, action.text])
				actionInfo = Magic.magics[action.text.to_lower()]
				actionInfo["damage"] = characterStats.attackElem * actionInfo["damageMultiplier"]
			
			"technique":
				print("%s is readying %s..." % [characterStats.characterName, action.text])
				actionInfo = Technique.techniques[action.text.to_lower()]
				actionInfo["damage"] = characterStats.attackPhys * actionInfo["damageMultiplier"]
		
		actionInfo["source"] = character
		
		match(category.to_lower()):
			"magic": emit_signal("magicReadied", actionInfo)
			"technique": emit_signal("techniqueReadied", actionInfo)


func _on_enemy_readied(actionType: int, actionInfo: Dictionary, selectedTargets: Array):
	match(actionType):
		GameData.ActionType.ATTACK:
			emit_signal("attackReadied", actionInfo, selectedTargets)
		GameData.ActionType.MAGIC:
			emit_signal("magicReadied", actionInfo, selectedTargets)
		GameData.ActionType.TECHNIQUE:
			emit_signal("techniqueReadied", actionInfo, selectedTargets)


func affect(actionInfo: Dictionary):
	# check if physical or elemental damage
	var finalDamage: int
	if actionInfo["damageType"] == GameData.DamageType.PHYSICAL:
		finalDamage = int(max(actionInfo["damage"] - (characterStats.defensePhys * 0.5), 1))
	else:
		finalDamage = int(max(actionInfo["damage"] - (characterStats.defenseElem * 0.5), 1))
	
	emit_signal("damaged")
	if characterStats.currentHealth - finalDamage <= 0:
		get_parent().visible = false
		queue_free()
		emit_signal("downed")
	characterStats.currentHealth -= finalDamage
	print("%s dealt %s damage to %s!" % [actionInfo["source"].name, finalDamage, characterStats.characterName])
	_update_health_bar()
