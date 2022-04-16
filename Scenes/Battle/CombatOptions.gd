extends Control
class_name CombatOptions


signal subContainerReadied()
signal subContainerClosed()

enum Buttons {ATTACK, MAGIC, TECHNIQUE, ITEM, DEFEND, FLEE}

onready var mainButtons: Array = $Container/Buttons.get_children()
onready var attackButton: Button = mainButtons[Buttons.ATTACK]
onready var magicButton: Button = mainButtons[Buttons.MAGIC]
onready var techniqueButton: Button = mainButtons[Buttons.TECHNIQUE]
onready var itemButton: Button = mainButtons[Buttons.ITEM]
onready var defendButton: Button = mainButtons[Buttons.DEFEND]
onready var fleeButton: Button = mainButtons[Buttons.FLEE]

onready var subContainer: Control = $SubContainer
onready var subContainerButtons: Array = $SubContainer/Buttons.get_children()

onready var label: Label = $Container/Label

var currentSubContainer: Button

var magics: Array # depends on CharacterStats.magics
var techniques: Array # depends on CharacterStats.techniques
var items: Array = [
	"Bautista Daily Special", "Inspiriting Plum (M)"
] # make an inventory


func _ready():
	_set_focus_neighbors($Container/Buttons)


func _ready_sub_container(array: Array):
	if array.empty():
		subContainer.grab_focus()
		subContainerButtons.clear()
		subContainer.get_node("ColorRect").rect_size.y = 20
	else:
		var newButton
		for item in array:
			newButton = Button.new()
			newButton.text = item
			subContainer.get_node("Buttons").add_child(newButton)
		_set_focus_neighbors($SubContainer/Buttons)
		subContainerButtons = subContainer.get_node("Buttons").get_children()
		subContainer.get_node("Buttons").get_child(0).grab_focus()
		
		# To make the bg scale with the number of buttons
		subContainer.get_node("ColorRect").rect_size.y = array.size() * 24 - 4
	emit_signal("subContainerReadied")
	subContainer.visible = true


func clear_sub_container():
	subContainerButtons = subContainer.get_node("Buttons").get_children()
	if subContainerButtons.empty():
		return
	for button in subContainerButtons:
		button.queue_free()


func _set_focus_neighbors(container: Control):
	var i: int = 0
	var buttons: Array = container.get_children()
	while i < buttons.size():
		buttons[i].focus_neighbour_top = buttons[i - 1].get_path()
		buttons[i].focus_neighbour_bottom = buttons[i + 1].get_path() if i != buttons.size() - 1 else buttons[0].get_path()
		i += 1


func _on_Magic_pressed():
	currentSubContainer = magicButton
	subContainer.rect_position.y = magicButton.rect_position.y + 24
	_ready_sub_container(magics)
func _on_Technique_pressed():
	currentSubContainer = techniqueButton
	subContainer.rect_position.y = techniqueButton.rect_position.y + 24
	_ready_sub_container(techniques)
func _on_Item_pressed():
	currentSubContainer = itemButton
	subContainer.rect_position.y = itemButton.rect_position.y + 24
	_ready_sub_container(items)


func _get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		if subContainer.visible:
			currentSubContainer.grab_focus()
			currentSubContainer = null
			clear_sub_container()
			subContainer.visible = false
			emit_signal("subContainerClosed")


func _physics_process(_delta):
	_get_input()
