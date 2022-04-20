extends Control


enum Side {LEFT, RIGHT}

onready var char1: TextureRect = $Character1
onready var char2: TextureRect = $Character2
onready var speakerLabel: RichTextLabel = $ColorRect/SpeakerLabel
onready var dialogueLabel: RichTextLabel = $ColorRect/DialogueLabel
onready var continueLabel: Label = $ColorRect/ContinueLabel
onready var timer: Timer = $Timer

# Array of [NAME OF PICTURE WITHOUT EXTENSION, SIDE, DIALOGUE]
var dialogueInfo: Array = [
	["Akune", Side.LEFT, "Hello, my name is Akune. Nulla facilisi."],
	["Elena", Side.RIGHT, "Hey, I'm Alabus. Maecenas cursus tortor sit amet viverra fermentum."],
	["Eo", Side.LEFT, "I'm Eo. Etiam consectetur vitae turpis eu luctus."],
	["Klyne", Side.RIGHT, "Hi there, I'm Klyne. Lorem ipsum dolor sit amet, consectetur adipiscing elit."]
]
var currentDialogue: Array = [] # dialogue to be displayed now
var page: int = 0


func _ready():
	_set_currentDialogue(page)
	timer.start()


func _physics_process(_delta):
	_get_input()
	
	if dialogueLabel.visible_characters > dialogueLabel.get_total_character_count():
		timer.stop()
		continueLabel.visible = true
	else:
		continueLabel.visible = false


func _get_input():
	if Input.is_action_just_pressed("ui_accept"):
		# if current line is finished printing
		if dialogueLabel.get_visible_characters() >= dialogueLabel.get_total_character_count():
			# if page is not the last
			if page < dialogueInfo.size() - 1:
				page += 1
				_set_currentDialogue(page)
				timer.start()
			# exit dialogue
			else:
				timer.stop()
				yield(get_tree().create_timer(0.5), "timeout")
				set_process(false)
				queue_free()
		else:
			dialogueLabel.set_visible_characters(999)


func _set_currentDialogue(newPage: int):
	dialogueLabel.visible_characters = 0
	currentDialogue = dialogueInfo[newPage]
	speakerLabel.bbcode_text = currentDialogue[0]
	dialogueLabel.bbcode_text = currentDialogue[2]
	if currentDialogue[1] == Side.LEFT:
		char1.texture = load("res://Assets/Character/Heroes/%s.png" % currentDialogue[0])
	else:
		char2.texture = load("res://Assets/Character/Heroes/%s.png" % currentDialogue[0])


func _on_Timer_timeout():
	dialogueLabel.visible_characters = dialogueLabel.visible_characters + 1
	# play sound
