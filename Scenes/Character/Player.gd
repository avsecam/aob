extends KinematicBody


signal step()

var distanceTraveled: float = 0 # should reset to 0 when it reaches EncounterHandler.STEP_SIZE
var currentPosition: Vector3
var lastPosition: Vector3

var velocity: Vector3 = Vector3()


func _ready():
	$Camera.look_at(translation, Vector3.UP)
	
	currentPosition = translation
	lastPosition = translation
	_set_leader_hero()
	
	connect("step", EncounterHandler, "_increment_step")


func _get_input():
	# ground movement
	var direction: Vector3 = Vector3()
	if Input.is_action_pressed("ui_up"):
		direction += Vector3(-1, 0, -1).normalized()
	if Input.is_action_pressed("ui_down"):
		direction += Vector3(1, 0, 1).normalized()
	if Input.is_action_pressed("ui_left"):
		direction += Vector3(-1, 0, 1).normalized()
	if Input.is_action_pressed("ui_right"):
		direction += Vector3(1, 0, -1).normalized()
	
	if Input.is_action_pressed("sprint"):
		velocity += direction * (PlayerData.WALK_SPEED + 4)
	else:
		velocity += direction * (PlayerData.WALK_SPEED)
	
	# jump
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y += PlayerData.JUMP_IMPULSE


func _physics_process(delta):
	_get_distance_traveled()
	_set_position_data()
	_get_input()
	
	# friction
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, PlayerData.FRICTION)
		velocity.z = lerp(velocity.z, 0, PlayerData.FRICTION)
	else:
		velocity.x = lerp(velocity.x, 0, PlayerData.FRICTION + 0.1)
		velocity.z = lerp(velocity.z, 0, PlayerData.FRICTION + 0.1)
	
	# keep player on floor
	velocity.y -= PlayerData.FALL_ACCELERATION * delta
	velocity = move_and_slide(velocity, Vector3.UP)


func _set_position_data():
	PlayerData.position = currentPosition


func _get_distance_traveled():
	lastPosition = currentPosition
	currentPosition = translation
	
	distanceTraveled += sqrt(pow(currentPosition.x - lastPosition.x, 2)) + pow(currentPosition.z - lastPosition.z, 2)
	
	if distanceTraveled >= EncounterHandler.STEP_SIZE:
		distanceTraveled = 0
		emit_signal("step")


func _set_leader_hero():
	var leaderHero: Spatial = load("%s%s.tscn" % [GameData.heroFolderPath, PlayerData.leaderHero.characterName]).instance()
	add_child(leaderHero)








