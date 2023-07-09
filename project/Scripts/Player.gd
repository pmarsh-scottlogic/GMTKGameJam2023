extends RigidBody2D

# Speed cap for adding force
@export var maxForce: float = 810

# Multiplier for magnitude
@export var forceMagnitudeMultiplier: float = 12

# Mouse held position
var leftMouseHeld: bool = false

# State for checking if the player is aiming
enum AimStates {IDLE, AIMING}
var aimstate: AimStates = AimStates.IDLE

# Time slowdown proportional speed
@export var timeSlowProportion : float = 0.1

@export var arrows: int = 30

@export var airbourne: bool

@export var fullDrawbackTime: float = 1
var currentDrawbackTime: float = 0
var drawbackMultiplier: float = 0

# The Indicator Arrow
@onready var line := $Line2D

# The Arrow
@onready var arrow := $BowArea/Arrow

# The Bow Area
@onready var bowArea := $BowArea

# Sound players
@onready var shootSoundPlayer := $soundPlayers/shootSoundPlayer
@onready var landSoundPlayer := $soundPlayers/landSoundPlayer

var mainNode: Node2D

var arrowScene: PackedScene = preload("res://Scenes/arrow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	mainNode = get_tree().get_root().get_node("MainNode")
	line.hide()
	arrow.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if aimstate == AimStates.AIMING:
		showLine()
	handleDrawback(delta)
	print("power: " + str(drawbackMultiplier))
	
func handleDrawback(delta):
	if leftMouseHeld:
		currentDrawbackTime += delta
		drawbackMultiplier = min(currentDrawbackTime / fullDrawbackTime, 1)
		
func showLine():
	line.show()
	arrow.show()
	line.points[0] = to_local(self.position)
	var magnitude: float = (get_global_mouse_position() - self.position).length() * drawbackMultiplier
	magnitude = min(magnitude, maxForce)
	var direction: Vector2 = (get_global_mouse_position() - self.position).normalized()
	line.points[1] = to_local(self.position + (direction * magnitude))

func playerArrowLaunch(force: Vector2):
	if arrows == 0:
		return
	self.linear_velocity = Vector2.ZERO
	apply_impulse(force)
	spawnArrow()
	arrows -= 1

func spawnArrow():
	var newArrow = arrowScene.instantiate()
	newArrow.position = arrow.global_position
	if(get_global_mouse_position().x > self.get_position().x):
		newArrow.rotation = bowArea.rotation
		newArrow.set_scale(Vector2(-1,1))
	else:
		newArrow.rotation = bowArea.rotation
	mainNode.add_child(newArrow)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT :
		if event.pressed:
			leftMouseHeld = true
			arrowAimLogic()
		elif !event.pressed:
			leftMouseHeld = false
			launchInputLogic()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT :
		if event.pressed:
			cancelAim()
		elif !event.pressed:
			pass

func _on_body_entered(body):
	landSoundPlayer.play()
	$impactParticles.restart()
	airbourne = false

func _on_body_exited(body):
	airbourne = true

func arrowAimLogic():
	if aimstate != AimStates.IDLE or arrows == 0:
		return
	Engine.time_scale = timeSlowProportion
	aimstate = AimStates.AIMING

func launchInputLogic():
	if aimstate != AimStates.AIMING :
		return
	var launch: Vector2 = (get_global_mouse_position() - self.position).normalized()
	var magnitude: float = (get_global_mouse_position() - self.position).length() * drawbackMultiplier
	if magnitude > maxForce:
		magnitude = maxForce
	magnitude *= forceMagnitudeMultiplier
	playerArrowLaunch(launch * magnitude)
	line.hide()
	arrow.hide()
	Engine.time_scale = 1
	shootSoundPlayer.play()
	aimstate = AimStates.IDLE
	currentDrawbackTime = 0;
	drawbackMultiplier = 0;

func cancelAim():
	if aimstate != AimStates.AIMING:
		return
	Engine.time_scale = 1
	aimstate = AimStates.IDLE
	line.hide()
	arrow.hide()

func _integrate_forces(state):
	if airbourne == false:
		if Input.is_action_pressed("ui_left"):
			apply_impulse(Vector2(-1,0) * 500.0)
		elif Input.is_action_pressed("ui_right"):
			apply_impulse(Vector2(1,0) * 500.0)
