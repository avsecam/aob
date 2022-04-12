extends Spatial


onready var combatInfo: VBoxContainer = $Billboard/Viewport/CombatInfo/Container/VBoxContainer
onready var characterName: Label = combatInfo.get_node("Label")
onready var healthBar: ProgressBar = combatInfo.get_node("Health")
onready var resourceBar: ProgressBar = combatInfo.get_node("Resource")

var character: Spatial # Hero or Enemy node
var characterInfo: CharacterStats
var isHero: bool = false


func _ready():
	# set the combat info
	characterName.text = characterInfo.characterName
	healthBar.max_value = characterInfo.maxHealth
	healthBar.value = characterInfo.currentHealth
	healthBar.get_node("Label").text = "%d / %d" % [characterInfo.currentHealth, characterInfo.maxHealth]
	resourceBar.max_value = characterInfo.maxResource
	resourceBar.value = characterInfo.currentResource
	resourceBar.get_node("Label").text = "%d / %d" % [characterInfo.currentResource, characterInfo.maxResource]
	
	# set the character scene to be shown
	if isHero:
		add_child(load("%s%s.tscn" % [GameData.heroFolderPath, characterInfo.characterName]).instance())
	else:
		add_child(load(GameData.enemyScenePath).instance()) # make this dynamic when enemy tscn's are added
	character = get_child(1)
