extends Spatial


func _ready():
	PlayerData.inBattle = true


func _get_input():
	if Input.is_action_just_pressed("ui_cancel"):
		_exit_battle()


func _physics_process(_delta):
	_get_input()


func _exit_battle():
	var world = load(PlayerData.location).instance()
	var overworld = GameData.main.get_node("Overworld")
	overworld.add_child(world)
	overworld.add_child(GameData.playerScene.instance())
	GameData.player = overworld.get_node("Player")
	GameData.player.translation = PlayerData.position
	PlayerData.inBattle = false
	queue_free()
