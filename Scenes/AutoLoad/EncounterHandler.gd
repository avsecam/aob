extends Node


onready var overworld = GameData.main.get_node("Overworld")

var battleScene = preload("res://Scenes/Battle/Battle.tscn")

const STEP_SIZE = 1
var steps = 0 # counts the steps made by player
var stepsTilEncounter = 0 # will be set to some number between minStepsForEncounter and maxStepsForEncounter
var minStepsForEncounter = 50
var maxStepsForEncounter = 100


func _ready():
	_set_steps_til_encounter()


func _physics_process(_delta):
	_set_encounter()


func _set_encounter():
	if stepsTilEncounter == 0:
		return
	if steps >= stepsTilEncounter:
		_encounter()
		steps = 0
		_set_steps_til_encounter()


func _encounter():	
	# free world and player then add battle scene
	for node in overworld.get_children():
		node.queue_free()
	GameData.main.add_child(battleScene.instance())


func _set_steps_til_encounter():
	randomize()
	stepsTilEncounter = randi() % (maxStepsForEncounter - minStepsForEncounter) + minStepsForEncounter


func _increment_step():
	steps += 1
