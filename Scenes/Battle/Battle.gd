extends Spatial


onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()
onready var gui: Control = $CombatGUI
onready var turnNumber: Label = $TurnNumber
onready var combatOptions: Control = $CombatGUI/HBoxContainer/CombatOptions

var turns: int = -1 # Number of turns cycled through
var turnOrder: Array


func _ready():
	PlayerData.inBattle = true
	
	_add_participants()
	_set_turn_order()
	_set_combat_options()
	_set_signals()
	
	combatOptions.buttons[1].connect("pressed", heroPositions[0].get_child(0), "_attack", [enemyPositions[0].get_child(0)])


func _add_participants():
	var combatCharacter: Spatial
	var heroes: Array = PlayerData.activeHeroes
	var enemies: Array = EncounterHandler.enemies
	var newEnemy: CharacterStats
	var i: int = 0
	while i < heroes.size():
		combatCharacter = load("res://Scenes/Battle/CombatCharacter.tscn").instance()
		combatCharacter.characterInfo = heroes[i]
		combatCharacter.isHero = true
		heroPositions[i].add_child(combatCharacter)
		i += 1
	
	i = 0
	while i < enemies.size():
		combatCharacter = load("res://Scenes/Battle/CombatCharacter.tscn").instance()
		newEnemy = load(enemies[i])
		newEnemy.ready()
		combatCharacter.characterInfo = newEnemy
		enemyPositions[i].add_child(combatCharacter)
		i += 1
	
	# clear empty positions
	for hero in heroPositions:
		if hero.get_child_count() <= 0:
			hero.queue_free()
			heroPositions.erase(hero)
	for enemy in enemyPositions:
		if enemy.get_child_count() <= 0:
			enemy.queue_free()
			enemyPositions.erase(enemy)


# Call at start and when turnOrder is empty (AKA turn order finished)
func _set_turn_order():
	turns += 1
	turnNumber.text = String(turns)
	turnOrder = []
	for character in heroPositions + enemyPositions:
		turnOrder.append(character)
	turnOrder.sort_custom(SortBySpeed, "_sort_speed")


# Next character in current turn queue
func _next_turn():
	turnOrder.remove(0)
	_set_combat_options()


# Show combat options or not
func _set_combat_options():
	var currentCharacter = turnOrder[0]
	if currentCharacter.get_parent().name == "Heroes":
		combatOptions.visible = true
		combatOptions.label.text = currentCharacter.get_child(0).characterInfo.characterName
		combatOptions.get_node("Container").get_child(1).grab_focus()
	else:
		combatOptions.visible = false


func _set_signals():
	for character in heroPositions + enemyPositions:
		character.get_child(0).connect("damaged", self, "_next_turn")


func _get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		_exit_battle()


func _physics_process(_delta):
	_get_input()


func _exit_battle():
	var world: Spatial = load(PlayerData.location).instance()
	var overworld: Spatial = GameData.main.get_node("Overworld")
	overworld.add_child(world)
	overworld.add_child(GameData.playerScene.instance())
	GameData.player = overworld.get_node("Player")
	GameData.player.translation = PlayerData.position
	PlayerData.inBattle = false
	queue_free()


class SortBySpeed:
	static func _sort_speed(a: Spatial, b: Spatial):
		if a.get_child(0).characterInfo.speed > b.get_child(0).characterInfo.speed:
			return true
		return false
