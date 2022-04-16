extends Spatial


onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()
onready var gui: Control = $CombatGUI
onready var turnNumber: Label = $TurnNumber
onready var combatOptions: CombatOptions = $CombatGUI/CombatOptions

var turns: int = -1 # Number of turns cycled through
var turnOrder: Array = []
var currentCharacterPosition: Position3D

var actionInfo: Dictionary
var inTargetSelect: bool = false
var targets: Array = [] # Array of positions

var totalExp: int # add to this when enemy is defeated or w/e


func _ready():
	PlayerData.inBattle = true
	
	_add_participants()
	_set_turn_order()
	_set_combat_options()
	_set_character_signals()
	
	combatOptions.connect("subContainerReadied", self, "_set_suboptions_signals")
	combatOptions.connect("subContainerClosed", self, "_unset_suboptions_signals")
	_set_options_signals()
	_set_suboptions_signals()


func _enter_target_select(info: Dictionary):
	actionInfo = info
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


func _confirm_action(target: Spatial):
	target.get_child(0).affect(actionInfo)
	combatOptions.subContainer.visible = false
	combatOptions.clear_sub_container()


func _add_participants():
	var combatCharacter: Spatial
	var heroes: Array = PlayerData.activeHeroes
	var enemies: Array = EncounterHandler.enemies
	var newEnemy: Enemy
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
		newEnemy = load(enemies[i]).instance()
		print(newEnemy.name)
		combatCharacter.add_child(newEnemy)
		combatCharacter.character = newEnemy
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
	currentCharacterPosition = turnOrder[0]


# Next character in current turn queue
func _next_turn():
	_unset_options_signals()
	turnOrder.remove(0)
	if turnOrder == []:
		_set_turn_order()
	else:
		currentCharacterPosition = turnOrder[0]
	_set_options_signals()
	_set_combat_options()


# Show combat options or not
# Also set the magics and techniques available
func _set_combat_options():
	var combatCharacter: CombatCharacter = currentCharacterPosition.get_child(0)
	if currentCharacterPosition.get_parent().name == "Heroes":
		combatOptions.visible = true
		combatOptions.label.text = combatCharacter.characterStats.characterName
		combatOptions.magics = combatCharacter.characterStats.magics
		combatOptions.attackButton.grab_focus()
	else:
		combatOptions.visible = false


func _set_character_signals():
	for character in heroPositions + enemyPositions:
		character.get_child(0).connect("damaged", self, "_next_turn")
	
	# basically, if downed, remove from the battle
	# change this behavior in the future
	for hero in heroPositions:
		hero.get_child(0).connect("downed", self, "_refresh_heroPositions")
	for enemy in enemyPositions:
		enemy.get_child(0).connect("downed", self, "_refresh_enemyPositions")


# set/unset signals for ATTACK, DEFEND, FLEE
func _set_options_signals():
	combatOptions.attackButton.connect("pressed", currentCharacterPosition.get_child(0), "attack")
	combatOptions.defendButton
	combatOptions.fleeButton.connect("pressed", self, "_exit_battle")
	
	currentCharacterPosition.get_child(0).connect("attack", self, "_enter_target_select")
	currentCharacterPosition.get_child(0).connect("magic", self, "_enter_target_select")
func _unset_options_signals():
	combatOptions.attackButton.disconnect("pressed", currentCharacterPosition.get_child(0), "attack")
	combatOptions.defendButton
	combatOptions.fleeButton.disconnect("pressed", self, "_exit_battle")
	
	currentCharacterPosition.get_child(0).disconnect("attack", self, "_enter_target_select")
	currentCharacterPosition.get_child(0).disconnect("magic", self, "_enter_target_select")


# set/unset signals for MAGICS and TECHNIQUES
func _set_suboptions_signals():
	var character = currentCharacterPosition.get_child(0)
	if combatOptions.currentSubContainer == combatOptions.magicButton:
		for button in combatOptions.subContainerButtons:
			button.connect("pressed", character, "magic", [button.text.to_lower()])
	elif combatOptions.currentSubContainer == combatOptions.techniqueButton:
		for button in combatOptions.subContainerButtons:
			button.connect("pressed", character, "technique", [button.text.to_lower()])
	elif combatOptions.currentSubContainer == combatOptions.itemButton:
		for button in combatOptions.subContainerButtons:
			button.connect("pressed", character, "item", [button.text.to_lower()])
func _unset_suboptions_signals():
	var character = currentCharacterPosition.get_child(0)
	if combatOptions.currentSubContainer == combatOptions.magicButton:
		for button in combatOptions.subContainerButtons:
			button.disconnect("pressed", character, "magic")
	elif combatOptions.currentSubContainer == combatOptions.techniqueButton:
		for button in combatOptions.subContainerButtons:
			button.disconnect("pressed", character, "technique")
	elif combatOptions.currentSubContainer == combatOptions.itemButton:
		for button in combatOptions.subContainerButtons:
			button.disconnect("pressed", character, "item")


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
				_confirm_action(target)
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
