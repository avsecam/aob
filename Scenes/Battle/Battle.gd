extends Spatial


onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()


func _ready():
	PlayerData.inBattle = true
	_add_participants()


func _add_participants():
	var combatCharacter: Spatial
	var heroes: Array = PlayerData.activeHeroes
	var enemies: Array = EncounterHandler.enemies
	var newEnemy: CharacterStats
	var i: int = 0
	while i < heroes.size():
		combatCharacter = load("res://Scenes/Character/CombatCharacter.tscn").instance()
		combatCharacter.characterInfo = heroes[i]
		combatCharacter.isHero = true
		heroPositions[i].add_child(combatCharacter)
		i += 1
	
	i = 0
	while i < enemies.size():
		combatCharacter = load("res://Scenes/Character/CombatCharacter.tscn").instance()
		newEnemy = load(enemies[i])
		newEnemy.ready()
		combatCharacter.characterInfo = newEnemy
		enemyPositions[i].add_child(combatCharacter)
		i += 1


func _get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		_exit_battle()


func _physics_process(_delta):
	_get_input()


func _exit_battle():
	var world = load(PlayerData.location).instance()
	var overworld = GameData.main.get_node("Overworld")
	overworld.add_child(world)
	overworld.add_child(GameData.playerScene.instance())
	GameData.player = overworld.get_node("Player")
	GameData.player.translation = PlayerData.position
	PlayerData.inBattle = false
	queue_free()
