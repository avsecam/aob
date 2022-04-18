extends Spatial


onready var heroPositions: Array = $Heroes.get_children()
onready var enemyPositions: Array = $Enemies.get_children()
onready var gui: Control = $CombatGUI
onready var turnNumberLabel: Label = $CombatGUI/TurnNumber
onready var actionNameLabel: Label = $CombatGUI/ActionName
onready var combatOptions: CombatOptions = $CombatGUI/CombatOptions

var characterPositions: Array # Contains enemyPositions + heroPositions

var turns: int = -1 # Number of turns cycled through
var turnOrder: Array = []
var currentCharacterPosition: Position3D

var actionInfo: Dictionary
var inTargetSelect: bool = false
var targets: Array = [] # Array of positions
var singleTargetIndex: int = 0 # index of current target in characterPositions (FOR SINGLE TARGET ONLY)

var totalExp: int # add to this when enemy is defeated or w/e


func _ready():
	PlayerData.inBattle = true
	
	_add_participants()
	_send_characterInfo_to_enemies()
	_set_turn_order()
	_set_combat_options()
	_set_character_signals()
	
	combatOptions.connect("subContainerReadied", self, "_set_suboptions_signals")
	combatOptions.connect("subContainerClosed", self, "_unset_suboptions_signals")
	_set_options_signals()
	_set_suboptions_signals()


func _enter_target_select(info: Dictionary, selectedTargets: Array = []):
	actionInfo = info
	combatOptions.attackButton.release_focus()
	
	if selectedTargets != []:
		targets = selectedTargets
		_refresh_target_selection()
		inTargetSelect = false
		_confirm_action()
	else:
		match(actionInfo["targetType"]):
			GameData.TargetType.SINGLE:
				targets.append(characterPositions[0])
			GameData.TargetType.GROUP:
				if actionInfo["offensive"]:
					targets.append_array(enemyPositions)
				else:
					targets.append_array(heroPositions)
			GameData.TargetType.ALL:
				targets.append_array(characterPositions)
		_refresh_target_selection()
		inTargetSelect = true


func _exit_target_select():
	actionInfo = {}
	inTargetSelect = false
	targets = []
	_refresh_target_selection()
	_set_combat_options()


func _single_target_move_choice(amount: int):
	singleTargetIndex += amount
	if singleTargetIndex < 0:
		singleTargetIndex = characterPositions.size() + amount
	elif singleTargetIndex >= characterPositions.size():
		singleTargetIndex = 0
	if characterPositions[singleTargetIndex] == currentCharacterPosition:
		if singleTargetIndex + amount < characterPositions.size():
			singleTargetIndex += amount
		else:
			singleTargetIndex = 0
	targets.append(characterPositions[singleTargetIndex])
	_refresh_target_selection()


func _refresh_target_selection():
	if inTargetSelect:
		match(actionInfo["targetType"]):
			GameData.TargetType.SINGLE:
				targets.remove(0)
			GameData.TargetType.GROUP:
				var previousSelectedGroup: Array = heroPositions if targets.find(enemyPositions[0]) else enemyPositions
				for character in previousSelectedGroup:
					targets.remove(0)
	for character in characterPositions:
		character.get_child(0).isSelected = false
	for target in targets:
		target.get_child(0).isSelected = true


func _confirm_action():
	actionNameLabel.text = actionInfo["name"]
	actionNameLabel.visible = true
	
	for target in targets:
		print(actionInfo)
		target.get_child(0).affect(actionInfo)
	
	combatOptions.subContainer.visible = false
	combatOptions.clear_sub_container()
	inTargetSelect = false
	yield(get_tree().create_timer(0.7),"timeout")
	actionNameLabel.text = ""
	_exit_target_select()
	actionNameLabel.visible = false
	_next_turn()


func _add_participants():
	var combatCharacter: Spatial
	var heroes: Array = PlayerData.activeHeroes
	var enemies: Array = EncounterHandler.enemies
	var newEnemy: Enemy # remove in the future
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
	
	characterPositions = enemyPositions + heroPositions


# send all combatants to enemies for targeting
func _send_characterInfo_to_enemies():
	var characterInfo: Array
	for character in characterPositions:
		characterInfo.append([character, character.get_child(0).characterStats])
	for enemy in enemyPositions:
		enemy.get_child(0).character.characterInfo = characterInfo
		enemy.get_child(0).character.set_characterInfo()


# Call at start and when turnOrder is empty (AKA turn order finished)
func _set_turn_order():
	turns += 1
	turnNumberLabel.text = "Turn %s" % turns
	turnOrder = []
	for character in characterPositions:
		turnOrder.append(character)
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
	if !currentCharacterPosition.get_child(0).isHero:
		currentCharacterPosition.get_child(0).action()


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
	# basically, if downed, remove from the battle
	# change this behavior in the future
	for hero in heroPositions:
		hero.get_child(0).connect("downed", self, "_refresh_heroPositions")
	for enemy in enemyPositions:
		enemy.get_child(0).connect("downed", self, "_refresh_enemyPositions")


# set/unset signals for ATTACK, DEFEND, FLEE
func _set_options_signals():
	var character = currentCharacterPosition.get_child(0)
	combatOptions.attackButton.connect("pressed", character, "action", [combatOptions.attackButton])
	combatOptions.defendButton
	combatOptions.fleeButton.connect("pressed", self, "_exit_battle")
	
	if character.isHero:
		character.connect("attackReadied", self, "_enter_target_select")
		character.connect("magicReadied", self, "_enter_target_select")
	else:
		character.connect("attackReadied", self, "_enter_target_select")
		character.connect("magicReadied", self, "_enter_target_select")
func _unset_options_signals():
	combatOptions.attackButton.disconnect("pressed", currentCharacterPosition.get_child(0), "action")
	combatOptions.defendButton
	combatOptions.fleeButton.disconnect("pressed", self, "_exit_battle")
	
	currentCharacterPosition.get_child(0).disconnect("attackReadied", self, "_enter_target_select")
	currentCharacterPosition.get_child(0).disconnect("magicReadied", self, "_enter_target_select")


# set/unset signals for MAGICS, TECHNIQUES, and ITEMS
func _set_suboptions_signals():
	for button in combatOptions.subContainerButtons:
		button.connect("pressed", currentCharacterPosition.get_child(0), "action", [button, combatOptions.currentSubContainer.text])
func _unset_suboptions_signals():
	for button in combatOptions.subContainerButtons:
		button.disconnect("pressed", currentCharacterPosition.get_child(0), "action")


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
	if inTargetSelect:
		# Selecting target
		match(actionInfo["targetType"]):
			GameData.TargetType.SINGLE:
				if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
					_single_target_move_choice(-1)
				elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
					_single_target_move_choice(1)
			
			GameData.TargetType.GROUP:
				if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") \
				or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
					if targets == enemyPositions:
						targets.append_array(heroPositions)
					else:
						targets.append_array(enemyPositions)
					_refresh_target_selection()
		
		# Confirming target
		if Input.is_action_just_pressed("ui_accept"):
			_confirm_action()
			
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
