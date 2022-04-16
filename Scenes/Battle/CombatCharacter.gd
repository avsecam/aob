extends Spatial
class_name CombatCharacter


signal attack(damage)
signal damaged()
signal downed()

onready var combatInfo: VBoxContainer = $Billboard/Viewport/CombatInfo/Container/VBoxContainer
onready var characterName: Label = combatInfo.get_node("Label")
onready var healthBar: ProgressBar = combatInfo.get_node("Health")
onready var resourceBar: ProgressBar = combatInfo.get_node("Resource")

var character: Spatial # Hero or Enemy node
var characterStats: CharacterStats
var isHero: bool = false
var isSelected: bool = false

func _ready():
	# set the character scene to be shown FOR ENEMIES ONLY (FOR NOW)
	if isHero:
		characterStats = character.characterStats
	else:
		add_child(load(GameData.enemyScenePath).instance()) # make this dynamic when enemy tscn's are added
		character = get_child(get_children().size() - 1)
	
	# set the combat info
	characterName.text = characterStats.characterName
	healthBar.max_value = characterStats.maxHealth
	resourceBar.max_value = characterStats.maxResource
	_update_health_bar()
	_update_resource_bar()


func _physics_process(_delta):
	if isSelected:
		character.sprite.modulate = Color(1, 0, 1, 1)
	else:
		character.sprite.modulate = Color(1, 1, 1, 1)


func _update_health_bar():
	healthBar.value = characterStats.currentHealth
	healthBar.get_node("Label").text = "%d / %d" % [characterStats.currentHealth, characterStats.maxHealth]
func _update_resource_bar():
	resourceBar.value = characterStats.currentResource
	resourceBar.get_node("Label").text = "%d / %d" % [characterStats.currentResource, characterStats.maxResource]


func attack(target: Spatial):
	var damageInfo: Dictionary = {
		"damage": characterStats.attackPhys,
		"type": "Physical"
	}
	connect("attack", target, "_on_damaged_physical")
	emit_signal("attack", damageInfo)
	disconnect("attack", target, "_on_damaged_physical")


func magic(target: Spatial):
	pass
	


func _on_damaged_physical(damageInfo: Dictionary):
	var finalDamage: int = damageInfo["damage"] - (characterStats.defensePhys * 0.5)
	emit_signal("damaged")
	if characterStats.currentHealth - finalDamage <= 0:
		get_parent().visible = false
		queue_free()
		emit_signal("downed")
	characterStats.currentHealth -= finalDamage
	_update_health_bar()


func _on_damaged_elemental(damageInfo: Dictionary):
	var finalDamage: int = damageInfo["damage"] - (characterStats.defensePhys * 0.5)
	emit_signal("damaged")
	if characterStats.currentHealth - finalDamage <= 0:
		get_parent().visible = false
		queue_free()
		emit_signal("downed")
	characterStats.currentHealth -= finalDamage
	_update_health_bar()
