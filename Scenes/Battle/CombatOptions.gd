extends Control


onready var buttons: Array = $Container/Buttons.get_children()
onready var label: Label = $Container/Label


func _ready():
	_set_focus_neighbors()


func _set_focus_neighbors():
	var i: int = 0
	while i < buttons.size():
		buttons[i].focus_neighbour_top = buttons[i - 1].get_path()
		buttons[i].focus_neighbour_bottom = buttons[i + 1].get_path() if i != buttons.size() - 1 else buttons[0].get_path()
		i += 1
