extends Spatial


export (String) var guiPath
onready var viewport = $Viewport
var gui # holds the control node
onready var quad = $Quad # use quad's texture to render gui


func _ready():
	viewport.add_child(load(guiPath).instance())
	gui = $Viewport.get_child(0)
	
	_render()


# render the gui to the quad
func _render():
	var guiSize = gui.rect_size
	
	viewport.size = guiSize
	
	quad.texture.viewport_path = viewport.get_path()
