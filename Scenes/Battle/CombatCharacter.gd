extends Spatial
class_name CombatCharacter


signal attack(damage)
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


func attack():
	print("%s is attacking..." % characterStats.characterName)
	var damageInfo: Dictionary = {
		"source": character,
		"targetType": GameData.TargetType.SINGLE,
		"damageType": GameData.DamageType.PHYSICAL,
		"damage": characterStats.attackPhys
	}
	emit_signal("attack", damageInfo)


func magic(spell: String):
	var damageInfoRaw: Dictionary = Magic.magics[spell.to_lower()]
	var damageInfo: Dictionary = {
		"source": character,
		"targetType": damageInfoRaw["targetType"],
		"damageType": damageInfoRaw["damageType"],
		"damage": characterStats.attackPhys *  damageInfoRaw["damageMultiplier"]
	}


func technique():
	pass
func item():
	pass


func affect(damageInfo: Dictionary):
	# check if physical or elemental damage
	var finalDamage: int
	if damageInfo["damageType"] == GameData.DamageType.PHYSICAL:
		finalDamage = damageInfo["damage"] - (characterStats.defensePhys * 0.5)
	else:
		finalDamage = damageInfo["damage"] - (characterStats.defenseElem * 0.5)
	
	emit_signal("damaged")
	if characterStats.currentHealth - finalDamage <= 0:
		get_parent().visible = false
		queue_free()
		emit_signal("downed")
	characterStats.currentHealth -= finalDamage
	print("%s dealt %s damage to %s!" % [damageInfo["source"].name, finalDamage, characterStats.characterName])
	_update_health_bar()
