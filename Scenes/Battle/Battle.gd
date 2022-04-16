extends Spatial


enum ActionType {ATTACK, MAGIC, TECHNIQUE, ITEM}

onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()
onready var gui: Control = $CombatGUI
onready var turnNumber: Label = $TurnNumber
onready var combatOptions: CombatOptions = $CombatGUI/CombatOptions

var turns: int = -1 # Number of turns cycled through
var turnOrder: Array = []
var currentCharacter: Position3D

var action: int

var inTargetSelect: bool = false
var targets: Array = [] # Array of positions


func _ready():
	PlayerData.inBattle = true
	
	_add_participants()
	_set_turn_order()
	_set_combat_options()
	_set_signals()


func _enter_target_select(actionType: int):
	action = actionType
	combatOptions.attackButton.release_focus()
	targets.append(enemyPositions[0])
	_refresh_target_selection()
	inTargetSelect = true


func _exit_target_select():
	inTargetSelect = false
	targets = []
	_refresh_target_selection()
	_set_combat_options()


func _refresh_target_selection():
	if inTargetSelect:
		targets.remove(0)
	for enemy in enemyPositions:
		enemy.get_child(0).isSelected = false
	for target in targets:
		target.get_child(0).isSelected = true


func _add_participants():
	var combatCharacter: Spatial
	var heroes: Array = PlayerData.activeHeroes
	var enemies: Array = EncounterHandler.enemies
	var newEnemy: CharacterStats
	var i: int = 0
	while i < heroes.size():
		combatCharacter = load("res://Scenes/Battle/CombatCharacter.tscn").instance()
		PlayerData.move_hero(heroes[i], PlayerData, combatCharacter)
		combatCharacter.character = combatCharacter.get_child(1)
		combatCharacter.character.visible = true
		combatCharacter.isHero = true
		heroPositions[i].add_child(combatCharacter)
		i += 1
	
	i = 0
	while i < enemies.size():
		combatCharacter = load("res://Scenes/Battle/CombatCharacter.tscn").instance()
		newEnemy = load(enemies[i])
		newEnemy.ready()
		combatCharacter.characterStats = newEnemy
		enemyPositions[i].add_child(combatCharacter)
		i += 1
	
	# clear empty positions
	for hero in heroPositions:
		if hero.get_child_count() <= 0:
			hero.free()
	_refresh_heroPositions()
	for enemy in enemyPositions:
		if enemy.get_child_count() <= 0:
			enemy.free()
	_refresh_enemyPositions()


# Call at start and when turnOrder is empty (AKA turn order finished)
func _set_turn_order():
	turns += 1
	turnNumber.text = String(turns)
	turnOrder = []
	for character in heroPositions + enemyPositions:
		turnOrder.append(character)
	turnOrder.pop_back()
	turnOrder.sort_custom(SortBySpeed, "_sort_speed")
	currentCharacter = turnOrder[0]


# Next character in current turn queue
func _next_turn():
	turnOrder.remove(0)
	if turnOrder == []:
		_set_turn_order()
		return
	currentCharacter = turnOrder[0]
	_set_combat_options()


# Show combat options or not
# Also set the magics and techniques available
func _set_combat_options():
	var combatCharacter: CombatCharacter = currentCharacter.get_child(0)
	if currentCharacter.get_parent().name == "Heroes":
		combatOptions.visible = true
		combatOptions.label.text = combatCharacter.characterStats.characterName
		combatOptions.magics = combatCharacter.characterStats.magics
		combatOptions.attackButton.grab_focus()
	else:
		combatOptions.visible = false


func _set_signals():
	combatOptions.attackButton.connect("pressed", self, "_enter_target_select", [ActionType.ATTACK])
	combatOptions.magicButton
	combatOptions.techniqueButton
	combatOptions.defendButton
	combatOptions.fleeButton.connect("pressed", self, "_exit_battle")
	
	for character in heroPositions + enemyPositions:
		character.get_child(0).connect("damaged", self, "_next_turn")
	
	for hero in heroPositions:
		hero.get_child(0).connect("downed", self, "_refresh_heroPositions")
	for enemy in enemyPositions:
		enemy.get_child(0).connect("downed", self, "_refresh_enemyPositions")


func _refresh_heroPositions():
	heroPositions = $Heroes.get_children()
	for hero in heroPositions:
		if !hero.visible:
			heroPositions.erase(hero)
func _refresh_enemyPositions():
	enemyPositions = $Enemies.get_children()
	for enemy in enemyPositions:
		if !enemy.visible:
			enemyPositions.erase(enemy)


func _get_input():
#	if Input.is_action_just_pressed("ui_cancel"):
#		_exit_battle()
	
	if inTargetSelect:
		# Selecting target
		var targetIndex: int = targets[0].get_index()
		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
			targets.append(enemyPositions[targetIndex - 1])
			_refresh_target_selection()
		elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
			if targetIndex >= enemyPositions.size() - 1:
				targets.append(enemyPositions[0])
			else:
				targets.append(enemyPositions[targetIndex + 1])
			_refresh_target_selection()
		
		# Confirming target
		elif Input.is_action_just_pressed("ui_accept"):
			for target in targets:
				currentCharacter.get_child(0).attack(target.get_child(0))
			_exit_target_select()
			
		# Cancel
		elif Input.is_action_just_pressed("ui_cancel"):
			_exit_target_select()


func _physics_process(_delta):
	_get_input()
	
	if enemyPositions == [] or heroPositions == []:
		_exit_battle()


func _exit_battle():
	var world: Spatial = load(PlayerData.location).instance()
	var overworld: Spatial = GameData.main.get_node("Overworld")
	overworld.add_child(world)
	
	# Move all the heroes back to PlayerData
	for hero in heroPositions:
		var combatCharacter = hero.get_node("CombatCharacter")
		var heroCharacter = hero.get_node("CombatCharacter").get_child(1)
		PlayerData.move_hero(heroCharacter, combatCharacter, PlayerData)
		combatCharacter.queue_free()
	
	overworld.add_child(GameData.playerScene.instance())
	GameData.player = overworld.get_node("Player")
	GameData.player.translation = PlayerData.position
	PlayerData.inBattle = false
	queue_free()


class SortBySpeed:
	static func _sort_speed(a: Spatial, b: Spatial):
		if a.get_child(0).characterStats.speed > b.get_child(0).characterStats.speed:
			return true
		return false
