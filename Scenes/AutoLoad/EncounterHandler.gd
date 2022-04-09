extends Node


onready var main = get_node("/root/Main")
onready var currentLevel = main.get_node("Overworld").get_child(0) # World

const STEP_SIZE = 1
var steps = 0 # counts the steps made by player
var stepsTilEncounter = 0 # will be set to some number between minStepsForEncounter and maxStepsForEncounter
var minStepsForEncounter = 50
var maxStepsForEncounter = 120


func _ready():
	_set_steps_til_encounter()


func _physics_process(delta):
	_set_encounter()


func _set_encounter():
	if stepsTilEncounter == 0:
		return
	if steps >= stepsTilEncounter:
		_encounter()
		randomize()
		steps = 0
		_set_steps_til_encounter()


func _encounter():
	print("ENEMY!@!!@# ", steps)
	
	# free overworld and add battle scene
	currentLevel.queue_free()
	main.add_child()


func _set_steps_til_encounter():
	stepsTilEncounter = randi() % (maxStepsForEncounter - minStepsForEncounter) + minStepsForEncounter


func _increment_step():
	steps += 1
