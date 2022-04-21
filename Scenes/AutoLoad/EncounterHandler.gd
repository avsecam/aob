extends Node


onready var overworld: Spatial

var battleScene: Resource = preload("res://Scenes/Battle/Battle.tscn")

const STEP_SIZE: float = 1.0
var steps: int = 0 # counts the steps made by player
var stepsTilEncounter: int = 0 # will be set to some number between MIN_STEPS_TIL_ENCOUNTER and MAX_STEPS_TIL_ENCOUNTER
const MIN_STEPS_TIL_ENCOUNTER: int = 50 - 40
const MAX_STEPS_TIL_ENCOUNTER: int = 100 - 60

# sample array of enemies
var enemies: Array = [
	"res://Scenes/Character/Enemy/LargeRat.tscn"
#	"res://Scenes/Character/Enemy/Slime.tres",
#	"res://Scenes/Character/Enemy/Quorralis.tres"
]


func _ready():
	_set_steps_til_encounter()


func _physics_process(_delta):
	return
	if stepsTilEncounter > 0 and steps >= stepsTilEncounter:
		_set_encounter()


func _set_encounter():
	_encounter()
	steps = 0
	_set_steps_til_encounter()


# free world and player then add battle scene
func _encounter():
	for node in overworld.get_children():
		if node.name == "Player":
			PlayerData.move_hero(node.character, node, PlayerData)
			PlayerData.move_child(PlayerData.get_child(PlayerData.get_child_count() - 1), 0)
		node.queue_free()
	GameData.main.add_child(battleScene.instance())


func _set_steps_til_encounter():
	randomize()
	stepsTilEncounter = randi() % (MAX_STEPS_TIL_ENCOUNTER - MIN_STEPS_TIL_ENCOUNTER) + MIN_STEPS_TIL_ENCOUNTER


func _increment_step():
	steps += 1
