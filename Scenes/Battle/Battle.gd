extends Spatial


onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()
onready var gui: Control = $CombatGUI

var turnOrder: Array


func _ready():
	PlayerData.inBattle = true
	
	_add_participants()
	_set_turn_order()
	
	gui.get_node("HBoxContainer/CombatOptions/Container").get_child(1).grab_focus()
	gui.get_node("HBoxContainer/CombatOptions").buttons[1].connect("pressed", heroPositions[0].get_child(0), "attack", [enemyPositions[0].get_child(0)])


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


func _set_turn_order():
	turnOrder = []
	for character in heroPositions + enemyPositions:
		turnOrder.append(character)
	print(turnOrder)


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
