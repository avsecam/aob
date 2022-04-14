extends Spatial
class_name CombatCharacter

signal attack(target, damage)
signal damaged(damage)

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
	resourceBar.max_value = characterInfo.maxResource
	_update_health()
	_update_resource()
	
	# set the character scene to be shown
	if isHero:
		add_child(load("%s%s.tscn" % [GameData.heroFolderPath, characterInfo.characterName]).instance())
	else:
		add_child(load(GameData.enemyScenePath).instance()) # make this dynamic when enemy tscn's are added
	character = get_child(1)


func _update_health():
	healthBar.value = characterInfo.currentHealth
	healthBar.get_node("Label").text = "%d / %d" % [characterInfo.currentHealth, characterInfo.maxHealth]
func _update_resource():
	resourceBar.value = characterInfo.currentResource
	resourceBar.get_node("Label").text = "%d / %d" % [characterInfo.currentResource, characterInfo.maxResource]


func attack(target: CombatCharacter):
	connect("attack", target, "_on_damaged")
	emit_signal("attack", characterInfo.attackPhys)
	disconnect("attack", target, "_on_damaged")


func _on_damaged(damage):
	characterInfo.currentHealth -= damage
	_update_health()
