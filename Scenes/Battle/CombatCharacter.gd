extends Spatial


signal attack(target, damage)
signal damaged()

onready var combatInfo: VBoxContainer = $Billboard/Viewport/CombatInfo/Container/VBoxContainer
onready var characterName: Label = combatInfo.get_node("Label")
onready var healthBar: ProgressBar = combatInfo.get_node("Health")
onready var resourceBar: ProgressBar = combatInfo.get_node("Resource")

var character: Spatial # Hero or Enemy node
var characterInfo: CharacterStats
var isHero: bool = false
var isSelected: bool = false

func _ready():
	# set the combat info
	characterName.text = characterInfo.characterName
	healthBar.max_value = characterInfo.maxHealth
	resourceBar.max_value = characterInfo.maxResource
	_update_health_bar()
	_update_resource_bar()
	
	# set the character scene to be shown
	if isHero:
		add_child(load("%s%s.tscn" % [GameData.heroFolderPath, characterInfo.characterName]).instance())
	else:
		add_child(load(GameData.enemyScenePath).instance()) # make this dynamic when enemy tscn's are added
	character = get_child(1)


func _physics_process(_delta):
	if isSelected:
		character.sprite.modulate = Color(1, 0, 1, 1)
	else:
		character.sprite.modulate = Color(1, 1, 1, 1)


func _update_health_bar():
	healthBar.value = characterInfo.currentHealth
	healthBar.get_node("Label").text = "%d / %d" % [characterInfo.currentHealth, characterInfo.maxHealth]
func _update_resource_bar():
	resourceBar.value = characterInfo.currentResource
	resourceBar.get_node("Label").text = "%d / %d" % [characterInfo.currentResource, characterInfo.maxResource]


func _attack(target: Spatial):
	connect("attack", target, "_on_damaged")
	emit_signal("attack", characterInfo.attackPhys)
	disconnect("attack", target, "_on_damaged")


func _on_damaged(damage):
	emit_signal("damaged")
	if characterInfo.currentHealth - damage <= 0:
		queue_free()
	characterInfo.currentHealth -= damage
	_update_health_bar()
