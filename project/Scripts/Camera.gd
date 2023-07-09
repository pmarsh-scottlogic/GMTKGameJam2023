extends Camera2D

@export var followPlayer := true
@export var maxSpeed : float = 10
@export var catchupSpeed : float = 5
@export var lookAheadDistance := 250
@export var timeUntilFollow : float = 0
var age = 0
var suppressFollowPlayer = false;

@onready var playerNode = get_tree().get_root().get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	if timeUntilFollow > 0 and followPlayer:
		suppressFollowPlayer = true
	
func getFollowPlayerTarget():
	var playerPos : Vector2 = get_node("../Player").position
	var mousePos : Vector2 = get_global_mouse_position()
	var cameraPosToMousePos := mousePos - position
	var mag = cameraPosToMousePos.length()
	var newMag : float = min(mag, lookAheadDistance)
	var target := playerPos + cameraPosToMousePos.normalized() * newMag
	return target

func getTarget():
	if followPlayer and not suppressFollowPlayer:
		return getFollowPlayerTarget()
	else:
		return position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	age += delta
	if timeUntilFollow > 0 and followPlayer:
		if age < timeUntilFollow:
			print("suppress")
			suppressFollowPlayer = true
		else:
			print("don't suppress")
			suppressFollowPlayer = false
	
	var target : Vector2 = getTarget()
	var positionToTarget : Vector2 = target - position
	var movementAmount = min(positionToTarget.length() * catchupSpeed * 0.001 * delta, maxSpeed * delta)
	
	position = position + positionToTarget * movementAmount
