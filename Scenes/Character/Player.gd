extends KinematicBody


signal step()


const FLOOR_NORMAL: Vector3 = Vector3.UP
const FLOOR_MAX_ANGLE: float = deg2rad(15)
const SNAP_DIRECTION: Vector3 = Vector3.DOWN
const SNAP_LENGTH: float = 1.0
const SNAP: Vector3 = SNAP_DIRECTION * SNAP_LENGTH # for move_and_slide_with_snap()

var character: Hero

var distanceTraveled: float = 0 # should reset to 0 when it reaches EncounterHandler.STEP_SIZE
var currentPosition: Vector3
var lastPosition: Vector3

var velocity: Vector3 = Vector3()


func _ready():
	GameData.player = self
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
	velocity.y = move_and_slide_with_snap(velocity, SNAP, FLOOR_NORMAL, true, 4, FLOOR_MAX_ANGLE).y


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
	PlayerData.remove_child(PlayerData.leaderHero)
	add_child(PlayerData.leaderHero)
	character = get_child(2)
	character.visible = true
