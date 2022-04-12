extends Spatial


export var renderPath: String = ""
onready var viewport: Viewport = $Viewport
onready var quad: Sprite3D = $Quad # use quad's texture to render gui
var gui: Control # holds the control node


func _physics_process(_delta):
	if renderPath != "" and !$Viewport.get_child(0):
		viewport.add_child(load(renderPath).instance())
		gui = $Viewport.get_child(0)
		_render()


# render the gui to the quad
func _render():
	var guiSize: Vector2 = gui.rect_size
	
	viewport.size = guiSize
	
	quad.texture.viewport_path = viewport.get_path()
